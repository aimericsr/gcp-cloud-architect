variable "credentials_file" {
  type        = string
  description = "Path to the service account credentials JSON file for GCP authentication."
}

variable "project_id" {
  type        = string
  description = "The ID of the GCP project where the resources will be created."
  default = "qwiklabs-gcp-03-c49e130c2434"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "us-east1"
}

variable "zone" {
  type        = string
  description = "The GCP zone"
  default     = "us-east1-c"
}
