output "source_disk" {
  value = google_compute_disk.minecraft-disk2.source_disk_id
}

output "source_image" {
  value = google_compute_disk.minecraft-disk2.source_image_id
}

output "source_snapshot_id" {
  value = google_compute_disk.minecraft-disk2.source_snapshot_id
}

output "self_link" {
  value = google_compute_disk.minecraft-disk2.self_link
}
