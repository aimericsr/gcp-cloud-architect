provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_datastream_connection_profile" "postgres-vm" {
  display_name = "postgres-vm"
  connection_profile_id = "dlsfd"
  location = "ldksjf"

  postgresql_profile {
    hostname       = "<INTERNAL_IP>"
    port       = 5432
    username   = "migration_admin"
    password   = "DMS_1s_cool!"
    database   = ""
  }
}
