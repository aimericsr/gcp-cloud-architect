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
  description                     = "mynetwork (Default)"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

# Allow all types of newtork calls inside the VPC
resource "google_compute_firewall" "default-allow-custom" {
  name      = "${google_compute_network.vpc-network-default.name}-allow-custom"
  network   = google_compute_network.vpc-network-default.name
  direction = "INGRESS"

  source_ranges = ["10.128.0.0/9"]

  priority = "65534"

  allow {
    protocol = "all"
  }
}

# Allow ping from anywhere
resource "google_compute_firewall" "default-allow-icmp" {
  name      = "${google_compute_network.vpc-network-default.name}-allow-icmp"
  network   = google_compute_network.vpc-network-default.name
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "65534"

  allow {
    protocol = "icmp"
  }
}

# allow rdp
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

#Allow SSH from anywhere
resource "google_compute_firewall" "default-allow-ssh" {
  name      = "${google_compute_network.vpc-network-default.name}-allow-ssh"
  network   = google_compute_network.vpc-network-default.name
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "65534"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

data "google_compute_default_service_account" "default" {
}

resource "google_compute_instance" "mynet-us-vm" {
  name         = "mynet-us-vm"
  machine_type = "e2-micro"
  zone         = "us-west3-b"
  #tags         = ["http-server", "https-server"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "mynetwork"
    access_config {
    }
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}

resource "google_compute_instance" "mynet-eu-vm" {
  name         = "mynet-eu-vm"
  machine_type = "e2-micro"
  zone         = "europe-west1-c"
  #tags         = ["http-server", "https-server"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "mynetwork"
    access_config {
    }
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
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
  ip_cidr_range = "10.240.0.0/20"
  region        = "us-west3"
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

resource "google_compute_instance" "managementnet-us-vm" {
  name         = "managementnet-us-vm"
  machine_type = "e2-micro"
  zone         = "us-west3-b"
  #tags         = ["http-server", "https-server"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "managementnet"
    subnetwork = "managementsubnet-us"
    access_config {
    }
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}






# New VPC
resource "google_compute_network" "privatenet" {
  name                            = "privatenet"
  description                     = "privatenet description"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "privatesubnet-us" {
  name          = "privatesubnet-us"
  ip_cidr_range = "172.16.0.0/24"
  region        = "us-west3"
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

resource "google_compute_instance" "privatenet-us-vm" {
  name         = "privatenet-us-vm"
  machine_type = "e2-micro"
  zone         = "us-west3-b"
  #tags         = ["http-server", "https-server"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "privatenet"
    subnetwork = "privatesubnet-us"
    access_config {
    }
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}
