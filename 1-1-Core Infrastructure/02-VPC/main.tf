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

resource "google_compute_network" "vpc-network-default" {
  name                            = "mynetwork"
  description                     = "Default VPC"
  auto_create_subnetworks         = true
  delete_default_routes_on_create = false
}

# Allow all types of newtork calls inside the VPC
# resource "google_compute_firewall" "default-allow-custom" {
#   name      = "${google_compute_network.vpc-network-default.name}-allow-custom"
#   network   = google_compute_network.vpc-network-default.name
#   direction = "INGRESS"

#   source_ranges = ["10.128.0.0/9"]

#   priority = "65534"

#   allow {
#     protocol = "all"
#   }
# }

# Allow ping from anywhere
# resource "google_compute_firewall" "default-allow-icmp" {
#   name      = "${google_compute_network.vpc-network-default.name}-allow-icmp"
#   network   = google_compute_network.vpc-network-default.name
#   direction = "INGRESS"

#   source_ranges = ["0.0.0.0/0"]

#   priority = "65534"

#   allow {
#     protocol = "icmp"
#   }
# }

resource "google_compute_firewall" "default-allow-rdp" {
  name      = "${google_compute_network.vpc-network-default.name}-allow-rdp"
  network   = google_compute_network.vpc-network-default.name
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "65534"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}

# Allow SSH from anywhere
# resource "google_compute_firewall" "default-allow-ssh" {
#   name      = "${google_compute_network.vpc-network-default.name}-allow-ssh"
#   network   = google_compute_network.vpc-network-default.name
#   direction = "INGRESS"

#   source_ranges = ["0.0.0.0/0"]

#   priority = "65534"

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }
# }

data "google_compute_default_service_account" "default" {
}

resource "google_compute_instance" "mynet-us-vm" {
  name         = "mynet-us-vm"
  machine_type = "e2-micro"
  zone         = "us-east5-b"
  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20230306"
      size  = 10
      type  = "pd-balanced"
    }
    auto_delete = true
    device_name = "mynet-us-vm"
  }

  network_interface {
    network    = "mynetwork"
    subnetwork = "mynetwork"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  metadata = {
    enable-oslogin = "true"
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }

  reservation_affinity {
    type = "ANY_RESERVATION"
  }

  shielded_instance_config {
    enable_vtpm                 = true
    enable_integrity_monitoring = true
    enable_secure_boot          = false
  }

  labels = {
    ec-src = "vm_add-gcloud"
  }
}


resource "google_compute_instance" "mynet-eu-vm" {
  name         = "mynet-eu-vm"
  machine_type = "e2-micro"
  zone         = "europe-west2-c"
  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20230306"
      size  = 10
      type  = "pd-balanced"
    }
    auto_delete = true
    device_name = "mynet-us-vm"
  }

  network_interface {
    network    = "mynetwork"
    subnetwork = "mynetwork"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  metadata = {
    enable-oslogin = "true"
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }

  reservation_affinity {
    type = "ANY_RESERVATION"
  }

  shielded_instance_config {
    enable_vtpm                 = true
    enable_integrity_monitoring = true
    enable_secure_boot          = false
  }

  labels = {
    ec-src = "vm_add-gcloud"
  }
}
