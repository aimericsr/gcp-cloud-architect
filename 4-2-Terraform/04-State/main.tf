terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.61.0"
    }
  }
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }

  # backend "gcs" {
  #   bucket = "qwiklabs-gcp-03-cdd220682cd0"
  #   prefix = "terraform/state"
  # }

}

provider "google" {
  credentials = file("key.json")


  project = "qwiklabs-gcp-03-cdd220682cd0"
  region  = "us-central1"
}

resource "google_storage_bucket" "test-bucket-for-state" {
  name                        = "qwiklabs-gcp-03-cdd220682cd0"
  location                    = "US"
  uniform_bucket_level_access = true
  force_destroy = true
}

