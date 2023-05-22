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




resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
  disable_dependent_services = true
}

resource "google_container_cluster" "primary" {
  name               = "webfrontend"
  location           = var.gcp_zone
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "webfrontend-nodes"
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  node_count = 2

  node_config {
    machine_type = "e2-medium"
  }
}