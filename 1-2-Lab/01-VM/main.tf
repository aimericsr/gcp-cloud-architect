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

resource "google_compute_firewall" "default-allow-http" {
  name      = "default-allow-http"
  network   = "default"
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

data "google_compute_default_service_account" "default" {
}

resource "google_compute_instance" "default" {
  name         = "gcelab"
  machine_type = "e2-medium"
  zone         = var.gcp_zone
  tags         = ["http-server"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size = 10
      }
  }
  network_interface {
    network = "default"
    # access config is for external IP
    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }

  metadata_startup_script = "${file("script.sh")}"
}

