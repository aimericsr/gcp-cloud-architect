provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_storage_bucket" "voicilestartupscript" {
  name     = "voicilestartupscript"
  location = "US"
  force_destroy = true
}


# VM
data "google_compute_default_service_account" "default" {
}

resource "google_compute_instance" "default" {
  name         = "default"
  machine_type = "n1-standard-1"
  zone         = var.zone
  tags         = ["http"]
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    access_config {

    }
    network = "default"
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }

  metadata = {
    startup-script-url = "https://storage.cloud.google.com/voicilestartupscript/install-web.sh"
  }
}

resource "google_compute_firewall" "default-allow-http" {
  name      = "default-allow-http"
  network   = "default"
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]

  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
