provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_project_iam_binding" "project" {
  project = "qwiklabs-gcp-00-bc7b2f21ded6"
  role    = "roles/viewer"
  members = [
    "user:student-02-d5080b967911@qwiklabs.net",
  ]
}

resource "google_project_iam_binding" "sa" {
  project = "qwiklabs-gcp-00-bc7b2f21ded6"
  role    = "roles/iam.serviceAccountUser"
  members = [
    "user:student-02-d5080b967911@qwiklabs.net",
  ]
}

resource "google_project_iam_binding" "custom-role" {
  project = "qwiklabs-gcp-00-bc7b2f21ded6"
  role    = "projects/qwiklabs-gcp-00-bc7b2f21ded6/roles/devops"
  members = [
    "user:student-02-d5080b967911@qwiklabs.net",
  ]
}

resource "google_project_iam_custom_role" "devops" {
  role_id     = "devops"
  title       = "My devops Role"
  description = "A description"
  permissions = ["compute.instances.create", "compute.instances.delete", "compute.instances.start", "compute.instances.stop", "compute.instances.update", "compute.disks.create", "compute.subnetworks.use", "compute.subnetworks.useExternalIp", "compute.instances.setMetadata", "compute.instances.setServiceAccount"]
}

resource "google_service_account" "devops" {
  account_id   = "devops"
  display_name = "devops"
}

# ???
resource "google_project_iam_binding" "devops-sau" {
  project = "qwiklabs-gcp-00-bc7b2f21ded6"
  role    = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:devops@qwiklabs-gcp-00-bc7b2f21ded6.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "devops-admin" {
  project = "qwiklabs-gcp-00-bc7b2f21ded6"
  role    = "roles/compute.instanceAdmin"
  members = [
    "serviceAccount:devops@qwiklabs-gcp-00-bc7b2f21ded6.iam.gserviceaccount.com",
  ]
}


resource "google_compute_instance" "lab-3" {
  name         = "lab-3"
  zone         = var.zone
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
    access_config {
      
    }
  }

  service_account {
    # gcloud compute instances list
    email  = "devops@qwiklabs-gcp-00-bc7b2f21ded6.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/compute"]
  }
}



#gcloud compute instances create lab-3 --service-account $SA --scopes "https://www.googleapis.com/auth/compute"

# 