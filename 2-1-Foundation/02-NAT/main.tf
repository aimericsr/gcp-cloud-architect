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

resource "google_compute_network" "privatenet" {
  name                            = "privatenet"
  description                     = "privatenet (Default)"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "privatenet-us" {
  name          = "privatenet-us"
  ip_cidr_range = "10.130.0.0/20"
  region        = "us-central1"
  network       = google_compute_network.privatenet.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "privatenet-allow-ssh" {
  name      = "${google_compute_network.privatenet.name}-allow-ssh"
  network   = google_compute_network.privatenet.name
  direction = "INGRESS"

  source_ranges = ["35.235.240.0/20"]

  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

data "google_compute_default_service_account" "default" {
}

resource "google_compute_instance" "vm-internal" {
  name         = "vm-internal"
  machine_type = "n1-standard-1"
  zone         = "us-central1-c"
  #tags         = ["http-server", "https-server"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = google_compute_network.privatenet.name
    subnetwork = google_compute_subnetwork.privatenet-us.name
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}

resource "google_storage_bucket" "jesuisunbucketsurgcp" {
  name          = "jesuisunbucketsurgcp"
  location      = "EU"
  force_destroy = true
}




resource "google_compute_router" "nat-router" {
  name    = "nat-router"
  region  = google_compute_subnetwork.privatenet-us.region
  network = google_compute_network.privatenet.id
}

resource "google_compute_router_nat" "nat-config" {
  name                               = "nat-config"
  region                             = google_compute_subnetwork.privatenet-us.region
  router                             = google_compute_router.nat-router.name

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}