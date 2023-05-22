terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
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



# VM
data "google_compute_default_service_account" "default" {
}

resource "google_compute_instance" "vm_instance" {
  name         = "nucleus-jumphost-175"
  zone         = var.gcp_zone
  machine_type = "f1-micro"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      }
  }

  #nucleus-vpc	

  network_interface {
    network = "default"
    access_config { 

    }
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}

# Kubernetes

resource "google_container_cluster" "primary" {
  name               = "nucleus-kube-1"
  location           = var.gcp_zone
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "nucleus-nodes-1"
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  node_count = 3

  node_config {
    machine_type = "n1-standard-1"
  }
}

# HTTP Load balancer


# # Create instance template
resource "google_compute_instance_template" "lb-backend-template" {
  name         = "lb-backend-template"
  machine_type = "f1-micro"
  tags         = ["allow-health-check"]

  network_interface {
    network = "default"
    access_config {
    }
  }

  disk {
    source_image = "debian-cloud/debian-11"
  }

  metadata_startup_script = file("script.sh")

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
  name = "permit-tcp-rule-632"
  network = "default"
  direction = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags = ["allow-health-check"]

  allow {
    protocol = "tcp"
    ports = ["80"]
  }
}

# # Not working
# # Create global static external IP address
# # resource "google_compute_global_address" "lb-ipv4-1" {
# #   provider = google-beta
# #   name = "lb-ipv4-1"
# #   address_type  = "EXTERNAL"
# #   ip_version = "IPV4"
# # }

# Create health check
resource "google_compute_health_check" "http-basic-check" {
  name               = "http-basic-check"
  check_interval_sec = 5
  timeout_sec        = 5
  tcp_health_check {
    port = "80"
  }
}

# Create backend service
resource "google_compute_backend_service" "web-backend-service" {
  name = "web-backend-service"
  protocol = "HTTP"
  port_name = "http"
  health_checks = [google_compute_health_check.http-basic-check.self_link]

  backend {
    group = google_compute_instance_group_manager.lb-backend-group.instance_group
  }
}

# URL map
resource "google_compute_url_map" "web-map-http" {
  name = "web-map-http"

  default_service = google_compute_backend_service.web-backend-service.self_link
}

# Proxy HTTP
resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.web-map-http.self_link
}

# Forwarding rule
resource "google_compute_global_forwarding_rule" "http-content-rule" {
  name       = "http-content-rule"
  target     = google_compute_target_http_proxy.http-lb-proxy.self_link
  port_range = "80"
  ip_address = "34.120.69.39"
  #ip_address = google_compute_global_address.lb-ipv4-1.address
}
