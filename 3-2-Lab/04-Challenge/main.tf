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


# Development VPC
resource "google_compute_network" "griffin-dev-vpc" {
  name                            = "griffin-dev-vpc"
  description                     = "VPC for Development"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "griffin-dev-wps" {
  name          = "griffin-dev-wp"
  ip_cidr_range = "192.168.16.0/20"
  region        = var.gcp_region
  network       = google_compute_network.griffin-dev-vpc.id
}

resource "google_compute_subnetwork" "griffin-dev-mgmt" {
  name          = "griffin-dev-mgmt"
  ip_cidr_range = "192.168.32.0/20"
  region        = var.gcp_region
  network       = google_compute_network.griffin-dev-vpc.id
}

resource "google_compute_firewall" "griffin-dev-allow-ssh" {
  name      = "${google_compute_network.griffin-dev-vpc.name}-allow-ssh"
  network   = google_compute_network.griffin-dev-vpc.name
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "65534"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Production VPC
resource "google_compute_network" "griffin-prod-vpc" {
  name                            = "griffin-prod-vpc"
  description                     = "VPC for production"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "griffin-prod-wp" {
  name          = "griffin-prod-wp"
  ip_cidr_range = "192.168.48.0/20"
  region        = var.gcp_region
  network       = google_compute_network.griffin-prod-vpc.id
}

resource "google_compute_subnetwork" "griffin-prod-mgmt" {
  name          = "griffin-prod-mgmt"
  ip_cidr_range = "192.168.64.0/20"
  region        = var.gcp_region
  network       = google_compute_network.griffin-prod-vpc.id
}

resource "google_compute_firewall" "griffin-prod-allow-ssh" {
  name      = "${google_compute_network.griffin-prod-vpc.name}-allow-ssh"
  network   = google_compute_network.griffin-prod-vpc.name
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "65534"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}


# NAT
resource "google_compute_router" "router" {
  name    = "nat-router-us-central1"
  region  = var.gcp_region
  network = google_compute_network.griffin-dev-vpc.self_link
}

resource "google_compute_router_nat" "nat-router" {
  name   = "nat-router-us-central1"
  region = var.gcp_region
  router = google_compute_router.router.name

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}

#VM
data "google_compute_default_service_account" "default" {
}

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "n1-standard-1"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.griffin-dev-mgmt.self_link
    # access_config {
    # }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.griffin-prod-mgmt.self_link
    # access_config {
    # }
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
  }
}

# # SQL
# gcloud services enable servicenetworking.googleapis.com --project=qwiklabs-gcp-02-6b0f3916d4b4
# https://cloud.google.com/sql/docs/mysql/configure-private-services-access?hl=fr
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 16
  network       = google_compute_network.griffin-dev-vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.griffin-dev-vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "griffin-dev-db" {
  name             = "griffin-dev-db"
  database_version = "MYSQL_5_7"
  depends_on       = [google_service_networking_connection.private_vpc_connection]
  region           = var.gcp_region
  settings {
    tier              = "db-n1-standard-1"
    availability_type = "REGIONAL"

    backup_configuration {
      enabled = true
      # only MySQL
      binary_log_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.griffin-dev-vpc.self_link
      # subnet ?
    }
  }
  #root_password       = "allo"
  deletion_protection = true
}

# resource "google_sql_database" "wordpress" {
#   name     = "wordpress"
#   instance = google_sql_database_instance.griffin-dev-db.name
# }

resource "google_sql_user" "root" {
  name     = "root"
  password = "allo"
  instance = google_sql_database_instance.griffin-dev-db.name
  type     = "BUILT_IN"
  host = "%"
}

# Script to setup the user

# CREATE USER "wp_user"@"%" IDENTIFIED BY "stormwind_rules";
# GRANT ALL PRIVILEGES ON wordpress.* TO "wp_user"@"%";
# FLUSH PRIVILEGES;


#Kubernetes
resource "google_container_cluster" "griffin-dev" {
  name               = "griffin-dev"
  location           = var.gcp_zone
  network                  = google_compute_network.griffin-dev-vpc.self_link
  subnetwork               = google_compute_subnetwork.griffin-dev-wps.self_link
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "griffin-dev_nodes_1" {
  name       = "griffin-dev-nodes-1"
  location   = var.gcp_zone
  cluster    = google_container_cluster.griffin-dev.id
  node_count = 2

  node_config {
    machine_type = "n1-standard-4"
  }

}

#Uptime Check
resource "google_monitoring_uptime_check_config" "wordpress_site" {
  display_name = "wordpress-site"
  timeout      = "60s"

  http_check {
    path           = "/"
    port           = "80"
    request_method = "GET"
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = "34.23.45.121"
    }
  }
}

#Add access to another enginner
resource "google_project_iam_member" "editor_enginer" {
  project = var.project_id
  role    = "roles/editor"
  member =  "user:student-02-30405ad0cff5@qwiklabs.net"
}

# resource "google_project_iam_binding" "editor_enginer_binding" {
#   project = var.project_id
#   role    = "roles/editor"
#   members = [ "user:student-02-30405ad0cff5@qwiklabs.net" ]
# }