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

resource "google_storage_bucket" "default" {
  name          = var.project_id
  location      = "US"
  force_destroy = true
}


# # Create a service account
# resource "google_service_account" "read_bucket_objects" {
#   project      = var.project_id
#   account_id   = "read-bucket-objects2"
#   display_name = "read-bucket-objects2"
# }

# # Grant the service account the Storage Object Viewer role
# resource "google_project_iam_member" "read_bucket_objects_storage_object_viewer" {
#   project = var.project_id
#   role    = "roles/storage.objectViewer"
#   member  = "serviceAccount:${google_service_account.read_bucket_objects.email}"
# }

# # Add a user to the service account
# resource "google_project_iam_member" "service_account_user" {
#   project    = var.project_id
#   role       = "roles/iam.serviceAccountUser"
#   member     = "group:altostrat.com"
#   depends_on = [google_service_account.read_bucket_objects]
# }


# # Grant Compute Engine access to the entire organization at Altostrat
# resource "google_project_iam_member" "compute_engine_admin" {
#   project = var.project_id
#   role    = "roles/compute.instanceAdmin.v1"
#   member  = "group:altostrat.com"
# }

# # Create a VM with the service account user
# resource "google_compute_instance" "demoiam" {
#   name         = "demoiam"
#   machine_type = "e2-micro"
#   zone         = "us-east5-a"

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }

#   network_interface {
#     network = "default"
#   }
  
#   service_account {
#     email  = google_service_account.read_bucket_objects.email
#     scopes = ["https://www.googleapis.com/auth/devstorage.read_write", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/trace.append"]
#   }
# }
