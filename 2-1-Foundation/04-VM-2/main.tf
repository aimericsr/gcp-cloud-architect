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

data "google_compute_default_service_account" "default" {
}

resource "google_compute_disk" "minecraft-disk2" {
  name = "minecraft-disk2"
  type = "pd-ssd"
  size = 50
}

resource "google_compute_address" "mc-ip-static2" {
  name         = "mc-ip-static2"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "mc-server2" {
  name         = "mc-server2"
  machine_type = "e2-medium"
  zone         = var.gcp_zone
  tags         = ["minecraft-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {
      // Static public IP
      nat_ip = google_compute_address.mc-ip-static2.address
    }
  }

  # ?????????
  attached_disk {
    source      = google_compute_disk.minecraft-disk2.id
    device_name = google_compute_disk.minecraft-disk2.name
  }
  metadata = {
    startup-script-url  = "https://storage.googleapis.com/cloud-training/archinfra/mcserver/startup.sh"
    shutdown-script-url = "https://storage.googleapis.com/cloud-training/archinfra/mcserver/shutdown.sh"
  }



  # For the attached disk
  lifecycle {
    ignore_changes = [attached_disk]
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_write", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.minecraft-disk2.id
  instance = google_compute_instance.mc-server2.id
}


# resource "google_compute_firewall" "minecraft-rule" {
#   name    = "minecraft-rule"
#   network = "default"
#   allow {
#     protocol = "tcp"
#     ports    = ["25565"]
#   }

#   source_ranges = ["0.0.0.0/0"]
#   target_tags = ["minecraft-server"] 
# }