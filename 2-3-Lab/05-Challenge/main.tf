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

# Cloud Storage
resource "google_storage_bucket" "image-storage" {
  name          = var.bucket_name 
  location      = "US"
}

# Pub/Sub
resource "google_pubsub_topic" "default" {
  name = var.topic_name
}

# Functions 
resource "google_storage_bucket" "code-storage" {
  name     = "jesuisunbucketpourstockerducode"
  location = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "archive" {
  name   = "code.zip"
  bucket = google_storage_bucket.code-storage.name
  source = "./code.zip" 
  content_encoding = "zip"
  content_type = "application/zip"
}

# Not working
# resource "google_cloudfunctions_function" "function" {
#   name = var.function_name

#   runtime = "nodejs14"
#   entry_point = "thumbnail"  

#   source_archive_bucket = google_storage_bucket.code-storage.name
#   source_archive_object = google_storage_bucket_object.archive.name

#   event_trigger {
#     event_type = "google.storage.object.finalize"
#     resource = google_storage_bucket.image-storage.name
#   }

# }
