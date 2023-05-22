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

variable "name" {
  type        = string
  description = "The name of the bucket"
}

variable "location" {
  type        = string
  description = "The location of the bucket"
}

variable "uniform_bucket_level_access" {
  type        = bool
   description = "Set the bucket level access"
}

variable "force_destroy" {
  type        = bool
  description = "Destroy the bucket even if there are objects inside"
}
