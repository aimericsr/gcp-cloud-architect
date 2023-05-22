terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.gcp_region
}

provider "google-beta" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.gcp_region
}

resource "google_service_account" "github_action_service_account" {
  account_id   = "je-suis-un-service-eaccount"
  display_name = "Testeuuh Service Account"
}

resource "google_project_iam_member" "github_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_action_service_account.email}"
}

resource "google_project_iam_member" "github_run" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.github_action_service_account.email}"
}