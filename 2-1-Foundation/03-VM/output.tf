output "instance_id" {
  value = google_compute_instance.vm3.instance_id
}

output "metadata_fingerprint" {
  value = google_compute_instance.vm3.metadata_fingerprint
}

output "self_link" {
  value = google_compute_instance.vm3.self_link
}

output "tags_fingerprint" {
  value = google_compute_instance.vm3.tags_fingerprint
}

output "label_fingerprint" {
  value = google_compute_instance.vm3.label_fingerprint
}

output "cpu_platform" {
  value = google_compute_instance.vm3.cpu_platform
}

output "network_ip" {
  value = google_compute_instance.vm3.network_interface.0.network_ip
}

output "nat_ip" {
  value = google_compute_instance.vm3.network_interface.0.access_config.0.nat_ip
}
