provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_container_cluster" "io" {
  name               = "standard-cluster-1"
  location           = var.zone
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "default-pool" {
  name       = "default-pool"
  location   = var.zone
  cluster    = google_container_cluster.io.name
  node_count = 3

  node_config {
    machine_type = "e2-small"
    # oauth_scopes    = [
    #   "https://www.googleapis.com/auth/cloud-platform"
    # ]
  }
}