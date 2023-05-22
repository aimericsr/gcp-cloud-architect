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


# New VPC
resource "google_compute_network" "managementnet" {
  name                            = "managementnet"
  description                     = "managementnet description"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "managementsubnet-us" {
  name          = "managementsubnet-us"
  ip_cidr_range = "10.130.0.0/20"
  region        = "us-east1"
  network       = google_compute_network.managementnet.id
}

resource "google_compute_firewall" "managementnet-allow-icmp-ssh-rdp" {
  name      = "${google_compute_network.managementnet.name}-allow-icmp-ssh-rdp"
  network   = google_compute_network.managementnet.name
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "1000"

  # ICMP
  allow {
    protocol = "icmp"
  }

  # ssh and rdp
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
}




resource "google_compute_network" "privatenet" {
  name                            = "privatenet"
  description                     = "privatenet"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "privatesubnet-us" {
  name          = "privatesubnet-us"
  ip_cidr_range = "172.16.0.0/24"
  region        = "us-east1"
  network       = google_compute_network.privatenet.id
}

resource "google_compute_subnetwork" "privatesubnet-eu" {
  name          = "privatesubnet-eu"
  ip_cidr_range = "172.20.0.0/20"
  region        = "europe-west1"
  network       = google_compute_network.privatenet.id
}



resource "google_compute_firewall" "privatenet-allow-icmp-ssh-rdp" {
  name      = "${google_compute_network.privatenet.name}-allow-icmp-ssh-rdp"
  network   = google_compute_network.privatenet.name
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "1000"

  # ICMP
  allow {
    protocol = "icmp"
  }

  # ssh and rdp
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
}




data "google_compute_default_service_account" "default" {
}




resource "google_compute_instance" "managementnet-us-vm" {
  name         = "managementnet-us-vm"
  machine_type = "e2-micro"
  zone         = "us-east1-c"
  #tags         = ["http-server", "https-server"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.managementsubnet-us.self_link
    access_config {
    }
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}


resource "google_compute_instance" "privatenet-us-vm" {
  name         = "privatenet-us-vm"
  machine_type = "e2-micro"
  zone         = "us-east1-c"
  #tags         = ["http-server", "https-server"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.privatesubnet-us.self_link
    access_config {
    }
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}

# VM with multiple network interface
resource "google_compute_instance" "vm-appliance" {
  name         = "vm-appliance"
  machine_type = "e2-standard-4"
  zone         = "us-east1-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }


  network_interface {
    subnetwork = google_compute_subnetwork.privatesubnet-us.self_link
    access_config {
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.managementsubnet-us.self_link
    access_config {
    }
  }

  network_interface {
    subnetwork = "mynetwork"
    access_config {
    }
  }


  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}












