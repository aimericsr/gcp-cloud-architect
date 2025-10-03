provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_container_cluster" "default" {
  name               = "onlineboutique-cluster-545"
  location           = var.zone
  remove_default_node_pool = true
  initial_node_count       = 1
  release_channel {
    channel = "RAPID"
  }
}

resource "google_container_node_pool" "default-pool" {
  name       = "default-pool"
  location   = var.zone
  cluster    = google_container_cluster.default.name
  node_count = 2

  node_config {
    machine_type = "n1-standard-2"
  }
}

# resource "google_container_node_pool" "optimized-pool" {
#   name       = "optimized-pool-1105"
#   location   = var.zone
#   cluster    = google_container_cluster.default.name
#   node_count = 2

#   node_config {
#     machine_type = "custom-2-3584"
#   }
# }