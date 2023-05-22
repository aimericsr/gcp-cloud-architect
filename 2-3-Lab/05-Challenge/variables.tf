variable "credentials_file" {
  type        = string
  description = "Path to the service account credentials JSON file for GCP authentication."
}

variable "project_id" {
  type        = string
  description = "The ID of the GCP project where the resources will be created."
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket"
  default = "memories-bucket-83227"
}

variable "topic_name" {
  type        = string
  description = "The name of the topic"
  default = "memories-topic-518"
}

variable "function_name" {
  type        = string
  description = "The name of the topic"
  default = "memories-thumbnail-creator"
}

variable "gcp_region" {
  type        = string
  description = "The GCP region"
  default     = "us-east1"
}

variable "gcp_zone" {
  type        = string
  description = "The GCP zone"
  default     = "us-east1-b"
}
