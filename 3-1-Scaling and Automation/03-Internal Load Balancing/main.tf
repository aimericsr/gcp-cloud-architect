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

resource "google_compute_firewall" "fw-allow-lb-access" {
  name      = "fw-allow-lb-access"
  network   = "my-internal-app"
  direction = "INGRESS"

  source_ranges = ["10.10.0.0/16"]
  target_tags   = ["backend-service"]

  priority = "1000"

  allow {
    protocol = "all"
  }

}

resource "google_compute_firewall" "fw-allow-health-checks" {
  name      = "fw-allow-health-checks"
  network   = "my-internal-app"
  direction = "INGRESS"

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["backend-service"]

  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

# NAT 
resource "google_compute_router" "nat-router" {
  name    = "nat-router-us-central1"
  region  = "us-central1"
  network = "my-internal-app"
}

resource "google_compute_router_nat" "nat-router-us-central1" {
  name   = "nat-router-us-central1"
  region = "us-central1"
  router = google_compute_router.nat-router.name

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}

# # VM
data "google_compute_default_service_account" "default" {
}

resource "google_compute_instance" "utility-vm" {
  name         = "utility-vm"
  machine_type = "n1-standard-1"
  zone         = "us-central1-f"
  tags         = ["allow-health-checks"]


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    network    = "my-internal-app"
    subnetwork = "subnet-a"
    network_ip = "10.10.20.50"
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}




# # # Internal Load Balancer

# # # Backend

# Create health check
resource "google_compute_region_health_check" "my-ilb-health-check" {
  name                = "my-ilb-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  tcp_health_check {
    port = "80"
  }
}

# # Create backend service
resource "google_compute_region_backend_service" "internal-tcp-backend" {
  # capacity = 1000
  name                  = "internal-tcp-backend"
  load_balancing_scheme = "INTERNAL"
  network               = "my-internal-app"
  protocol              = "TCP"
  health_checks         = [google_compute_region_health_check.my-ilb-health-check.self_link]


  backend {
    group = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/us-central1-a/instanceGroups/instance-group-1"
  }

  backend {
    group = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/us-central1-b/instanceGroups/instance-group-2"
  }
}


# # Frontend

# Create internal IP 
resource "google_compute_address" "my-ilb-ip" {
  name         = "my-ilb-ip"
  subnetwork   = "subnet-b"
  address_type = "INTERNAL"
  address      = "10.10.30.5"
}

# Forwarding rule
resource "google_compute_forwarding_rule" "tcp-content-rule" {
  name            = "tcp-content-rule"
  backend_service = google_compute_region_backend_service.internal-tcp-backend.id
  ports           = ["80"]
  region                = "us-central1"
  subnetwork            = "subnet-b"
  ip_address            = google_compute_address.my-ilb-ip.address
  load_balancing_scheme = "INTERNAL"
  ip_protocol           = "TCP"
}
