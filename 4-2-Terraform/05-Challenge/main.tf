provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "tf-instance-1" {
  source = "./modules/instances"
  name = "tf-instance-1"
  machine_type = "n1-standard-2"
  boot_disk_image = "debian-cloud/debian-10"
  #network_interface = "default"
  network_interface = module.vpc.subnets["us-east1/subnet-01"].self_link
  metadata_startup_script = "#!/bin/bash\n"
  allow_stopping_for_update = true
}

module "tf-instance-2" {
  source = "./modules/instances"
  name = "tf-instance-2"
  machine_type = "n1-standard-2"
  boot_disk_image = "debian-cloud/debian-10"
  #network_interface = "default"
  network_interface = module.vpc.subnets["us-east1/subnet-02"].self_link
  metadata_startup_script = "#!/bin/bash\n"
  allow_stopping_for_update = true
}

# module "tf-instance-3" {
#   source = "./modules/instances"
#   name = "tf-instance-139570"
#   machine_type = "n1-standard-2"
#   boot_disk_image = "debian-cloud/debian-10"
#   network_interface = "default"
#   metadata_startup_script = "#!/bin/bash\n"
#   allow_stopping_for_update = true
# }

module "tf-bucket" {
  source = "./modules/storage"
  name = "tf-bucket-512558"
  location = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "6.0.0"

    project_id   = var.project_id
    network_name = "tf-vpc-568075"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "us-east1"
        },
         {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "us-east1"
        }
    ]
}

resource "google_compute_firewall" "tf-firewall" {
  name      = "tf-firewall"
  network   = module.vpc.network_self_link
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  priority = "1000"

  allow {
    protocol = "tcp"
    ports = [ "80" ]
  }
}
