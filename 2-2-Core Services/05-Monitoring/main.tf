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


# resource "google_monitoring_alert_policy" "alert_policy" {
#   display_name = "My Alert Policy"
#   combiner     = "OR"
#   conditions {
#     display_name = "test condition"
#     condition_threshold {
#       filter     = "metric.type=\"compute.googleapis.com/instance/disk/write_bytes_count\" AND resource.type=\"gce_instance\""
#       duration   = "60s"
#       comparison = "COMPARISON_GT"
#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_RATE"
#       }
#     }
#   }

#   user_labels = {
#     foo = "bar"
#   }
# }

# resource "google_monitoring_group" "basic" {
#   display_name = "tf-test MonitoringGroup"

#   filter = "resource.metadata.region=\"europe-west2\""
# }

resource "google_monitoring_uptime_check_config" "http" {
  display_name = "http-uptime-check"
  timeout      = "60s"

  http_check {
    path = "/"
    port = "80"
    request_method = "GET"

    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }

  }

  # resource_group {
  #   resource_type ="INSTANCE"
  #   group_id = google_monitoring_group.basic.name
  # }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = "104.198.229.250"
    }
  }


}

resource "google_monitoring_uptime_check_config" "http-internal" {
  display_name = "http-uptime-check-internal"
  timeout      = "60s"

  http_check {
    path = "/"
    port = "80"
    request_method = "GET"

    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }

  }

  # resource_group {
  #   resource_type ="INSTANCE"
  #   group_id = "VM instances"
  # }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = "10.128.0.3"
    }
  }


}