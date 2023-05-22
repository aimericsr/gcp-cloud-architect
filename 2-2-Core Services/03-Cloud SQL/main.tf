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

# enable API servicenetworking.googleapis.com
# not working

resource "google_compute_global_address" "private_ip_block" {
  name          = "private-ip-block"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 20
  network       = "https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-02-b3fe8e1aec59/global/networks/default"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = "https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-02-b3fe8e1aec59/global/networks/default"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}

resource "google_sql_database_instance" "wordpress-db" {
  name             = "wordpress-db"
  database_version = "MYSQL_5_7"
  depends_on       = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"

    disk_size = 10

    ip_configuration {
      ipv4_enabled    = false
      private_network = "https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-02-b3fe8e1aec59/global/networks/default"
    }

    backup_configuration {
      enabled = true
      # only MySQL
      binary_log_enabled = true
    }

  }

  root_password = "jesuisunmdp"

  deletion_protection = true
} 