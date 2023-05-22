output "external_ip" {
  description = "VM external IP"
  value       = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}


