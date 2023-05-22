terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.61.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

resource "google_pubsub_topic" "myTopic" {
  name = "myTopic"

  labels = {
    foo = "bar"
  }

  #message_retention_duration = "86600s"
}


resource "google_pubsub_subscription" "mySubscription" {
  name  = "mySubscription"
  topic = google_pubsub_topic.myTopic.name
}