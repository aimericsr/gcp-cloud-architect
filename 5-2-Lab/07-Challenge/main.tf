provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# resource "google_project_iam_binding" "antern_editor" {
#   project = var.project_id
#   role    = "roles/cloudsql.instanceUser"
#   members = [
#     "user:student-00-5eb8db2e63ba@qwiklabs.net",
#   ]
# }

# resource "google_project_iam_binding" "cymbal_owner" {
#   project = var.project_id
#   role    = "roles/cloudsql.admin"
#   members = [
#     "user:student-00-2506dacdadbe@qwiklabs.net",
#   ]
# }

# resource "google_project_iam_binding" "cymbal_editor" {
#   project = var.project_id
#   role    = "roles/editor"
#   members = [
#     "user:student-00-c44130a6283a@qwiklabs.net",
#   ]
# }


resource "google_compute_network" "vpc-network-9kjp" {
  name                            = "vpc-network-9kjp"
  description                     = "Custom VPC"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "subnet-a-5pj1" {
  name          = "subnet-a-5pj1"
  ip_cidr_range = "10.10.10.0/24"
  region        = "europe-west2"
  network       = google_compute_network.vpc-network-9kjp.id
}

resource "google_compute_subnetwork" "subnet-b-n0ai" {
  name          = "subnet-b-n0ai"
  ip_cidr_range = "10.10.20.0/24"
  region        = "asia-south1"
  network       = google_compute_network.vpc-network-9kjp.id
}


resource "google_compute_firewall" "pqfi-firewall-ssh" {
  name        = "pqfi-firewall-ssh"
  network       = google_compute_network.vpc-network-9kjp.id
  source_ranges = [ "0.0.0.0/0" ]
  destination_ranges = ["10.10.10.0/24", "10.10.20.0/24"]
  priority = 65535
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "cuef-firewall-rdp" {
  name        = "cuef-firewall-rdp"
  network       = google_compute_network.vpc-network-9kjp.id
  source_ranges = [ "0.0.0.0/0" ]
  destination_ranges = ["10.10.10.0/24", "10.10.20.0/24"]
  priority = 65535
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}

resource "google_compute_firewall" "usoy-firewall-icmp" {
  name        = "usoy-firewall-icmp"
  network       = google_compute_network.vpc-network-9kjp.id
  source_ranges = [ "0.0.0.0/0" ]
  destination_ranges = ["10.10.10.0/24", "10.10.20.0/24"]
  priority = 65535
  direction = "INGRESS"

  allow {
    protocol = "imcp"
  }
}