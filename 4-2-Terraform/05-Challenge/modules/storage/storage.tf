resource "google_storage_bucket" "bucket" {
  name                        = var.name
  location                    = var.location
  uniform_bucket_level_access = var.uniform_bucket_level_access
  force_destroy = var.force_destroy
}