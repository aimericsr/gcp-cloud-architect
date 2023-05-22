terraform {
  # backend "local" {
  #   path = "terraform/state/terraform.tfstate"
  # }

  # export GOOGLE_APPLICATION_CREDENTIALS=key.json
  backend "gcs" {
    bucket = "tf-bucket-512558"
    prefix = "terraform/state"
  }

}