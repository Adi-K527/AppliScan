output "gcr_name" {
    value = google_cloud_run_service.cloud_run_service.name
}

output "gcr_url" {
    value = google_cloud_run_service.cloud_run_service.status[0].url
}