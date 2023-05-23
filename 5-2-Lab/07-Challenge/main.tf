provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "taw-custom-network" {
  name                            = "taw-custom-network"
  description                     = "Custom VPC"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "subnet-us-central" {
  name          = "subnet-us-central"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.taw-custom-network.id
}

resource "google_compute_subnetwork" "subnet-europe-west" {
  name          = "subnet-europe-west"
  ip_cidr_range = "10.1.0.0/16"
  region        = "europe-west1"
  network       = google_compute_network.taw-custom-network.id
}

resource "google_compute_subnetwork" "subnet-asia-east" {
  name          = "subnet-asia-east"
  ip_cidr_range = "10.2.0.0/16"
  region        = "asia-east1"
  network       = google_compute_network.taw-custom-network.id
}

resource "google_compute_firewall" "nw101-allow-http" {
  name        = "nw101-allow-http"
  network     = google_compute_subnetwork.subnet-us-central.name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"]
}

resource "google_compute_firewall" "nw101-allow-icmp" {
  name        = google_compute_subnetwork.subnet-us-central.name
  network     = "taw-custom-network"
  allow {
    protocol = "icmp"
  }
  target_tags = ["rules"]
}

resource "google_compute_firewall" "nw101-allow-internal" {
  name        = google_compute_subnetwork.subnet-us-central.name
  network     = "taw-custom-network"
  source_ranges = ["10.0.0.0/16", "10.2.0.0/16", "10.1.0.0/16"]
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "nw101-allow-ssh" {
  name        = google_compute_subnetwork.subnet-us-central.name
  network     = "taw-custom-network"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
}

resource "google_compute_firewall" "nw101-allow-rdp" {
  name        = google_compute_subnetwork.subnet-us-central.name
  network     = "taw-custom-network"
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}

data "google_compute_default_service_account" "default" {}
resource "google_compute_instance" "us-test-01" {
  name         = "us-test-01"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  tags         = ["ssh", "http", "rules"]
  boot_disk {
    auto_delete = false
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet-us-central.name
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}

resource "google_compute_instance" "europe-test-01" {
  name         = "europe-test-01"
  machine_type = "f1-micro"
  zone         = "europe-west1-b"
  tags         = ["ssh", "http", "rules"]
  boot_disk {
    auto_delete = false
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet-europe-west.name
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}

resource "google_compute_instance" "asia-test-01" {
  name         = "asia-test-01"
  machine_type = "f1-micro"
  zone         = "asia-east1-a"
  tags         = ["ssh", "http", "rules"]
  boot_disk {
    auto_delete = false
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet-asia-east.name
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}

resource "google_compute_instance" "us-test-02" {
  name         = "us-test-02"
  machine_type = "f1-micro"
  zone         = "us-central1-b"
  tags         = ["ssh", "http", "rules"]
  boot_disk {
    auto_delete = false
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet-us-central.name
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}
