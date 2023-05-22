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
  uniform_bucket_level_access = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 31
    }
    action {
      type = "Delete"
    }
  }

}

resource "google_storage_object_acl" "image-store-acl" {
  bucket = google_storage_bucket.default.name
  object = "setup.html"

  #predefined_acl = "publicRead" 

  role_entity = [
    "OWNER:user-student-01-51d9b8454b4c@qwiklabs.net",
    "READER:allUsers",
  ]
}
