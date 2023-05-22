terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.61.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.61.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

provider "google-beta" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

# Allow Health Check
resource "google_compute_firewall" "fw-allow-health-checks" {
  name      = "fw-allow-health-checks"
  network   = "default"
  direction = "INGRESS"

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-checks"]

  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

# NAT 
resource "google_compute_router" "nat-router-us-central1" {
  name    = "nat-router-us-central1"
  region  = "us-central1"
  network = "default"
}

resource "google_compute_router_nat" "nat-config" {
  name   = "nat-config"
  region = "us-central1"
  router = google_compute_router.nat-router-us-central1.name

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}

# VM
data "google_compute_default_service_account" "default" {
}

resource "google_compute_instance" "webserver" {
  name         = "webserver"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  tags         = ["allow-health-checks"]

  desired_status = "TERMINATED"

  boot_disk {
    auto_delete = false
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    network = "default"
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}



# Create custom image
# resource "google_compute_image" "mywebserver" {
#   name = "mywebserver"

#   source_disk = google_compute_instance.webserver.self_link
# }

# Use cutom image
data "google_compute_image" "mywebserver" {
  name = "mywebserver"
}


# # Instance Template
resource "google_compute_instance_template" "mywebserver-template" {
  name         = "mywebserver-template"
  machine_type = "f1-micro"
  tags         = ["allow-health-checks"]

  network_interface {
    network = "default"
  }

  disk {
    source_image = data.google_compute_image.mywebserver.self_link
    # device_name = "mywebserver"
    # disk_name = "mywebserver"
  }
}

# # # Health check for managed instance groups
resource "google_compute_health_check" "http-health-check" {
  name               = "http-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  tcp_health_check {
    port = "80"
  }
}

# # Create managed instance group
resource "google_compute_region_instance_group_manager" "us-central1-mig" {
  name   = "us-central1-mig"
  region = "us-central1"
  #zone               = "us-central1-a"
  base_instance_name = "us-central1-backend"
  version {
    instance_template = google_compute_instance_template.mywebserver-template.self_link
  }

  #target_size = 2

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http-health-check.self_link
    initial_delay_sec = 60
  }
}

resource "google_compute_region_autoscaler" "us-central1-mig-scale" {
  name   = "us-central1-mig-scale"
  region = "us-central1"
  target = google_compute_region_instance_group_manager.us-central1-mig.self_link
  autoscaling_policy {
    min_replicas = 1
    max_replicas = 2
    load_balancing_utilization {
      target = 0.8
    }
    cooldown_period = 60
  }
}

resource "google_compute_region_instance_group_manager" "europe-west1-mig" {
  name   = "europe-west1-mig"
  region = "europe-west1"
  #zone               = "europe-west1-b"
  base_instance_name = "europe-west1-backend"
  version {
    instance_template = google_compute_instance_template.mywebserver-template.self_link
  }
  #target_size = 2

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http-health-check.self_link
    initial_delay_sec = 60
  }
}

resource "google_compute_region_autoscaler" "europe-west1-mig-scale" {
  name   = "europe-west1-mig-scale"
  region = "europe-west1"
  target = google_compute_region_instance_group_manager.europe-west1-mig.self_link
  autoscaling_policy {
    min_replicas = 1
    max_replicas = 2
    load_balancing_utilization {
      target = 0.8
    }
    cooldown_period = 60
  }
}



# # # HTTP Load Balancer

# # # Backend

# # Create backend service
resource "google_compute_backend_service" "http-backend" {
  name          = "http-backend"
  protocol      = "HTTP"
  port_name     = "http"
  health_checks = [google_compute_health_check.http-health-check.self_link]

  load_balancing_scheme = "EXTERNAL"

  log_config {
    enable      = true
    sample_rate = 1
  }

  backend {
    balancing_mode        = "RATE"
    capacity_scaler       = 1
    max_rate_per_instance = 50
    group                 = google_compute_region_instance_group_manager.us-central1-mig.instance_group
  }

  backend {
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1
    max_utilization = 0.8
    group           = google_compute_region_instance_group_manager.europe-west1-mig.instance_group
  }
}




# # # Frontend

# Create global static external IP address

# resource "google_compute_address" "my-ephemeral-address" {
#   name   = "my-ephemeral-address"
#   #region = "us-central1"
#   address_type = "EXTERNAL"
#   #purpose = "VPC_PEERING"
# }


resource "google_compute_global_address" "lb-ipv4" {
  provider = google-beta
  name = "lb-ipv4-1"
  address_type  = "EXTERNAL"
  ip_version = "IPV4"
}

resource "google_compute_global_address" "lb-ipv6" {
  provider = google-beta
  name = "lb-ipv6-1"
  address_type  = "EXTERNAL"
  ip_version = "IPV6"
}

# URL map (name of the load balancer)
resource "google_compute_url_map" "http-lb" {
  name = "http-lb"

  default_service = google_compute_backend_service.http-backend.self_link
}

# # Proxy HTTP
resource "google_compute_target_http_proxy" "http-lb-proxy-ipv4" {
  name    = "http-lb-proxy-ipv4"
  url_map = google_compute_url_map.http-lb.self_link
}

# # Proxy HTTP
resource "google_compute_target_http_proxy" "http-lb-proxy-ipv6" {
  name    = "http-lb-proxy-ipv6"
  url_map = google_compute_url_map.http-lb.self_link
}

# # Forwarding rule (frontend)
resource "google_compute_global_forwarding_rule" "http-content-rule-ipv4" {
  name       = "http-content-rule-ipv4"
  target     = google_compute_target_http_proxy.http-lb-proxy-ipv4.self_link
  port_range = "80"
  ip_address = google_compute_global_address.lb-ipv4.address
}

resource "google_compute_global_forwarding_rule" "http-content-rule-ipv6" {
  name       = "http-content-rule-ipv6"
  target     = google_compute_target_http_proxy.http-lb-proxy-ipv6.self_link
  port_range = "80"
  ip_address = google_compute_global_address.lb-ipv6.address
}


# Create VM for the stress test
resource "google_compute_instance" "stress-test" {
  name         = "stress-test"
  machine_type = "f1-micro"
  zone         = "us-west1-b"


  boot_disk {
    initialize_params {
      image = data.google_compute_image.mywebserver.self_link
    }
  }
  network_interface {
    network = "default"
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}