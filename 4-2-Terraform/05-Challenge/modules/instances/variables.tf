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
  description = "The instance name"
}

variable "network_interface" {
  type        = string
  description = "The network self link"
}

variable "boot_disk_image" {
  type        = string
  description = "The boot disk image"
}

variable "machine_type" {
  type        = string
  description = "The instance type"
  default     = "e2-micro"
}

variable "allow_stopping_for_update" {
  type        = bool
  description = "Is the machine can stop for update"
}

variable "metadata_startup_script" {
  type        = string
  description = "The script"
}
