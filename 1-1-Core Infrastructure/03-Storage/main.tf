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

# resource "google_compute_firewall" "default-allow-http" {
#   name      = "default-allow-http"
#   network   = "default"
#   direction = "INGRESS"

#   source_ranges = ["0.0.0.0/0"]

#   priority = "1000"

#   allow {
#     protocol = "tcp"
#     ports    = ["80"]
#   }
# }

# resource "google_compute_instance" "vm_instance" {
#   name         = "bloghost"
#   machine_type = "e2-medium"
#   zone         = var.gcp_zone
#   tags         = ["http-server"]
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#       }
#   }
#   network_interface {
#     network = "default"
#     # access config is for external IP
#     access_config {
#       # Allocate a one-to-one NAT IP to the instance
#     }
#   }

#   service_account {
#     email  = data.google_compute_default_service_account.default.email
#     scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
#   }

#   metadata_startup_script = "${file("script.sh")}"
# }

resource "google_storage_bucket" "default" {
  name          = var.project_id
  location      = "EU"
  force_destroy = true
}

# # # Create a MySQL Cloud SQL instance
resource "google_sql_database_instance" "blog-db" {
  name             = "blog-db"
  database_version = "MYSQL_5_7"
  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    backup_configuration {
      enabled = true
      # only MySQL
      binary_log_enabled = true
    }

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "web front end"
        #value = "${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}/32"
        value = "35.199.174.80/32"
      }
    }
  }
  deletion_protection = false
  
}

# Add a user to the Cloud SQL instance
resource "google_sql_user" "blogdbuser" {
  name     = "blogdbuser"
  instance = google_sql_database_instance.blog-db.name
  password = "jesuissecret"
}

# Allow access from the bloghost VM instance
# resource "google_sql_database_instance_ip_configuration" "web-front-end" {
#   name   = "web-front-end"
#   instance = google_sql_database_instance.blog-db.name
#   authorized_networks {
#     name  = "web front end"
#     value = "google_compute_instance.mynet-eu-vm.network_interface.0.access_config.0.nat_ip/32"
#   }
# }
