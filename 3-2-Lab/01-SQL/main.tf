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

resource "google_sql_database_instance" "my-demo" {
  name             = "my-demo"
  database_version = "MYSQL_5_7"
  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"
    backup_configuration {
      enabled = true
      # only MySQL
      binary_log_enabled = true
    }

    ip_configuration {
      ipv4_enabled = true
    }
  }
  #root_password = "jesuisunmdp"
  deletion_protection = true 
}

resource "google_sql_database" "bike" {
  name     = "my-bike"
  instance = google_sql_database_instance.my-demo.name
}