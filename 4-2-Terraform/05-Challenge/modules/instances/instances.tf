# data "google_compute_default_service_account" "default" {
# }

resource "google_compute_instance" "default" {
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type
  #tags         = ["network-lb-tag"]
  #desired_status = "RUNNING"

  labels = {
    goog-dm = "qldm-55845507-2beb6a266a092f93"
  }
  boot_disk {
    initialize_params {
      image = var.boot_disk_image
    }
  }
  network_interface {
    subnetwork = var.network_interface
    access_config {
    }
  }

  service_account {
    email  = "qwiklabs-gcp-03-c49e130c2434@qwiklabs-gcp-03-c49e130c2434.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    startup-script = var.metadata_startup_script
  }

  timeouts {
    
  }

  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
    
  #metadata_startup_script = var.metadata_startup_script
  allow_stopping_for_update = var.allow_stopping_for_update
}