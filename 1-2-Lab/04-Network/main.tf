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
  # region  = var.gcp_region
  # zone    = var.gcp_zone
}


# VMs and firewall rule
module "ww1" {
  source                  = "./instance"
  instance_name           = "www1"
  instance_zone           = var.gcp_zone
  instance_type           = "e2-small"
  instance_network        = "default"
  instance_startup_script = "scripts/script1.sh"
}

module "ww2" {
  source                  = "./instance"
  instance_name           = "www2"
  instance_zone           = var.gcp_zone
  instance_type           = "e2-small"
  instance_network        = "default"
  instance_startup_script = "scripts/script2.sh"
}

module "ww3" {
  source                  = "./instance"
  instance_name           = "www3"
  instance_zone           = var.gcp_zone
  instance_type           = "e2-small"
  instance_network        = "default"
  instance_startup_script = "scripts/script3.sh"
}

resource "google_compute_firewall" "www-firewall-network-lb" {
  name      = "www-firewall-network-lb"
  network   = "default"
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["network-lb-tag"]
}

# Network load balancer

# Static external public IP adress
resource "google_compute_address" "network-lb-ip-1" {
  name = "network-lb-ip-1"
}

# Legacy health check
resource "google_compute_http_health_check" "basic-check" {
  name               = "basic-check"
  request_path = "/"
  check_interval_sec = 5
  timeout_sec        = 5
  port = 80
}

resource "google_compute_target_pool" "www-pool" {
  name = "www-pool"
  health_checks = [google_compute_http_health_check.basic-check.self_link]

  instances = [
    "${var.gcp_zone}/www1",
    "${var.gcp_zone}/www2",
    "${var.gcp_zone}/www3",
  ]
}

resource "google_compute_forwarding_rule" "www-rule" {
  name               = "www-rule"
  ip_address         = google_compute_address.network-lb-ip-1.address
  port_range         = "80"
  target             = google_compute_target_pool.www-pool.self_link
}



# HTTP load balancer

# Create instance template
resource "google_compute_instance_template" "lb-backend-template" {
  name         = "lb-backend-template"
  machine_type = "e2-medium"
  tags         = ["allow-health-check"]

  network_interface {
    network = "default"
    access_config {
    }
  }

  disk {
    source_image = "debian-cloud/debian-11"
  }

  metadata_startup_script = file("scripts/vm.sh")

}

# Create managed instance group
resource "google_compute_instance_group_manager" "lb-backend-group" {
  name = "lb-backend-group"
  zone = var.gcp_zone
  base_instance_name = "lb-backend"
  version {
    instance_template = google_compute_instance_template.lb-backend-template.self_link
  }
  target_size = 2

  named_port {
    name = "http"
    port = 80
  }

}

# # Create firewall rule
resource "google_compute_firewall" "fw-allow-health-check" {
  name = "fw-allow-health-check"
  network = "default"
  direction = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags = ["allow-health-check"]

  allow {
    protocol = "tcp"
    ports = ["80"]
  }
}

# Not working for the lab but working
# Create global static external IP address
resource "google_compute_global_address" "lb-ipv4-1" {
  provider = google-beta
  name = "lb-ipv4-1"
  address_type  = "EXTERNAL"
  ip_version = "IPV4"
}

# Create health check
resource "google_compute_health_check" "http-basic-check" {
  name               = "http-basic-check"
  check_interval_sec = 5
  timeout_sec        = 5
  tcp_health_check {
    port = "80"
  }
}

# # Create backend service
resource "google_compute_backend_service" "web-backend-service" {
  name = "web-backend-service"
  protocol = "HTTP"
  port_name = "http"
  health_checks = [google_compute_health_check.http-basic-check.self_link]

  backend {
    group = google_compute_instance_group_manager.lb-backend-group.instance_group
  }
}

# # URL map
resource "google_compute_url_map" "web-map-http" {
  name = "web-map-http"

  default_service = google_compute_backend_service.web-backend-service.self_link
}

# # Proxy HTTP
resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.web-map-http.self_link
}

# # Forwarding rule
resource "google_compute_global_forwarding_rule" "http-content-rule" {
  name       = "http-content-rule"
  target     = google_compute_target_http_proxy.http-lb-proxy.self_link
  port_range = "80"
  ip_address = google_compute_global_address.lb-ipv4-1.address
}
