resource "google_artifact_registry_repository" "model_bucket_gcp_registry" {
  provider = google

  repository_id = "appliscan-gcp-registry"
  location      = "us-central1"
  format        = "DOCKER"
  description   = "Docker repository for Appliscan backend"
}


resource "google_cloud_run_service" "cr_backend" {
  name     = "appliscan-cloudrun-backend-8264"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/google-samples/hello-app:1.0"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth_backend" {
  location    = google_cloud_run_service.cr_backend.location
  project     = google_cloud_run_service.cr_backend.project
  service     = google_cloud_run_service.cr_backend.name

  policy_data = data.google_iam_policy.noauth.policy_data
}