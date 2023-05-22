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

# GCP Network
resource "google_compute_network" "vpc-demo" {
  name                            = "vpc-demo"
  description                     = "Demo VPC"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false

  # enable HA VPN to work if the regions of the 2 VMs is not the samme (cross regions)
  routing_mode = "GLOBAL"
}

resource "google_compute_subnetwork" "vpc-demo-subnet1" {
  name          = "vpc-demo-subnet1"
  ip_cidr_range = "10.1.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc-demo.id
}

resource "google_compute_subnetwork" "vpc-demo-subnet2" {
  name          = "vpc-demo-subnet2"
  ip_cidr_range = "10.2.1.0/24"
  region        = "us-east1"
  network       = google_compute_network.vpc-demo.id
}

resource "google_compute_firewall" "vpc-demo-allow-custom" {
  name      = "${google_compute_network.vpc-demo.name}-allow-custom"
  network   = google_compute_network.vpc-demo.name
  direction = "INGRESS"

  source_ranges = ["10.0.0.0/8"]

  priority = "65534"

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

resource "google_compute_firewall" "vpc-demo-allow-ssh-icmp" {
  name      = "${google_compute_network.vpc-demo.name}-allow-ssh-icmp"
  network   = google_compute_network.vpc-demo.name
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "65534"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }
}

data "google_compute_default_service_account" "default" {
}

resource "google_compute_instance" "vpc-demo-instance1" {
  name         = "vpc-demo-instance1"
  machine_type = "f1-micro"
  zone         = "us-central1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.vpc-demo-subnet1.self_link
    access_config {

    }
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}

resource "google_compute_instance" "vpc-demo-instance2" {
  name         = "vpc-demo-instance2"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.vpc-demo-subnet2.self_link
    access_config {

    }
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}




# On Premise Network
resource "google_compute_network" "on-prem" {
  name                            = "on-prem"
  description                     = "On premise VPC"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "on-prem-subnet1" {
  name          = "on-prem-subnet1"
  ip_cidr_range = "192.168.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.on-prem.id
}


resource "google_compute_firewall" "on-prem-allow-custom" {
  name      = "${google_compute_network.on-prem.name}-allow-custom"
  network   = google_compute_network.on-prem.name
  direction = "INGRESS"

  source_ranges = ["192.168.0.0/16"]

  priority = "65534"

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

resource "google_compute_firewall" "on-prem-allow-ssh-icmp" {
  name      = "${google_compute_network.on-prem.name}-allow-ssh-icmp"
  network   = google_compute_network.on-prem.name
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "65534"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_instance" "on-prem-instance1" {
  name         = "on-prem-instance1"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.on-prem-subnet1.self_link
    access_config {

    }
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}


# HA VPN 
resource "google_compute_ha_vpn_gateway" "vpc-demo-vpn-gw1" {
  name    = "vpc-demo-vpn-gw1"
  network = google_compute_network.vpc-demo.id
  region  = "us-central1"
}

resource "google_compute_ha_vpn_gateway" "on-prem-vpn-gw1" {
  name    = "on-prem-vpn-gw1"
  network = google_compute_network.on-prem.id
  region  = "us-central1"
}

# Router
resource "google_compute_router" "vpc-demo-router1" {
  name    = "vpc-demo-router1"
  network = google_compute_network.vpc-demo.id
  region  = "us-central1"
  bgp {
    asn = 65001
  }
}

resource "google_compute_router" "on-prem-router1" {
  name    = "on-prem-router1"
  network = google_compute_network.on-prem.id
  region  = "us-central1"
  bgp {
    asn = 65002
  }
}

# Tunnel
resource "google_compute_vpn_tunnel" "vpc-demo-tunnel0" {
  name          = "vpc-demo-tunnel0"
  region        = "us-central1"
  vpn_gateway        = google_compute_ha_vpn_gateway.vpc-demo-vpn-gw1.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.on-prem-vpn-gw1.id
  shared_secret = "[SHARED_SECRET]"
  router        = google_compute_router.vpc-demo-router1.id
  vpn_gateway_interface = 0

  ike_version                     = 2
}

resource "google_compute_vpn_tunnel" "vpc-demo-tunnel1" {
  name          = "vpc-demo-tunnel1"
  region        = "us-central1"
  vpn_gateway        = google_compute_ha_vpn_gateway.vpc-demo-vpn-gw1.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.on-prem-vpn-gw1.id
  shared_secret = "[SHARED_SECRET]"
  router        = google_compute_router.vpc-demo-router1.id
  vpn_gateway_interface = 1

  ike_version                     = 2
}

resource "google_compute_vpn_tunnel" "on-prem-tunnel0" {
  name          = "on-prem-tunnel0"
  region        = "us-central1"
  vpn_gateway        = google_compute_ha_vpn_gateway.on-prem-vpn-gw1.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.vpc-demo-vpn-gw1.id
  shared_secret = "[SHARED_SECRET]"
  router        = google_compute_router.on-prem-router1.id
  vpn_gateway_interface = 0

  ike_version                     = 2
}

resource "google_compute_vpn_tunnel" "on-prem-tunnel1" {
  name          = "on-prem-tunnel1"
  region        = "us-central1"
  vpn_gateway        = google_compute_ha_vpn_gateway.on-prem-vpn-gw1.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.vpc-demo-vpn-gw1.id
  shared_secret = "[SHARED_SECRET]"
  router        = google_compute_router.on-prem-router1.id
  vpn_gateway_interface = 1

  ike_version                     = 2
}

# For each tunnels(4), we need to configure BGP session

# Tunnel0 / VPC demo
resource "google_compute_router_interface" "vpc-demo-router0" {
  name       = "if-tunnel0-to-on-prem"
  router     = google_compute_router.vpc-demo-router1.name
  region     = "us-central1"
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.vpc-demo-tunnel0.name
}

resource "google_compute_router_peer" "vpc-demo-router_bgp_peer0" {
  name            = "bgp-on-prem-tunnel0"
  router          = google_compute_router.vpc-demo-router1.name
  region          = "us-central1"
  peer_ip_address = "169.254.0.2"
  peer_asn        = 65002
  interface       = google_compute_router_interface.vpc-demo-router0.name
}

# Tunnel1 / VPC demo
resource "google_compute_router_interface" "vpc-demo-router1" {
  name       = "if-tunnel1-to-on-prem"
  router     = google_compute_router.vpc-demo-router1.name
  region     = "us-central1"
  ip_range   = "169.254.1.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.vpc-demo-tunnel1.name
}

resource "google_compute_router_peer" "vpc-demo-router_bgp_peer1" {
  name            = "bgp-on-prem-tunnel1"
  router          = google_compute_router.vpc-demo-router1.name
  region          = "us-central1"
  peer_ip_address = "169.254.1.2"
  peer_asn        = 65002
  interface       = google_compute_router_interface.vpc-demo-router1.name
}

#Tunnel0 / VPC on promise
resource "google_compute_router_interface" "on-prem-router0" {
  name       = "if-tunnel0-to-vpc-demo"
  router     = google_compute_router.on-prem-router1.name
  region     = "us-central1"
  ip_range   = "169.254.0.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.on-prem-tunnel0.name
}

resource "google_compute_router_peer" "on-prem-router_bgp_peer0" {
  name            = "bgp-vpc-demo-tunnel0"
  router          = google_compute_router.on-prem-router1.name
  region          = "us-central1"
  peer_ip_address = "169.254.0.1"
  peer_asn        = 65001
  interface       = google_compute_router_interface.on-prem-router0.name
}

#Tunnel1 / VPC on promise
resource "google_compute_router_interface" "on-prem-router1" {
  name       = "if-tunnel1-to-vpc-demo"
  router     = google_compute_router.on-prem-router1.name
  region     = "us-central1"
  ip_range   = "169.254.1.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.on-prem-tunnel1.name
}

resource "google_compute_router_peer" "on-prem-router_bgp_peer1" {
  name            = "bgp-vpc-demo-tunnel1"
  router          = google_compute_router.on-prem-router1.name
  region          = "us-central1"
  peer_ip_address = "169.254.1.1"
  peer_asn        = 65001
  interface       = google_compute_router_interface.on-prem-router1.name
}