resource "google_artifact_registry_repository" "gcp_registry" {
  provider = google

  repository_id = var.registry_name
  location      = "us-central1"
  format        = "DOCKER"
}