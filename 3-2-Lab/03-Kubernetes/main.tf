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


resource "google_container_cluster" "bootcamp" {
  name               = "bootcamp"
  location           = var.gcp_zone
  remove_default_node_pool = true
  initial_node_count       = 1

  
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "bootcamp-nodes-1"
  location   = var.gcp_zone
  cluster    = google_container_cluster.bootcamp.name
  node_count = 3

  node_config {
    machine_type = "e2-small"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

}