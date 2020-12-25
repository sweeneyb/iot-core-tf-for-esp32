resource "random_id" "project" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    proj_id = var.proj_id
  }

  byte_length = 8
}


data "google_billing_account" "acct" {
  display_name = "My Billing Account"
  open         = true
}

resource "google_project" "iot-project" {
  name       = "IoT Project"
  project_id = "iot-project-${random_id.project.hex}"
  billing_account = data.google_billing_account.acct.id

}


resource "google_pubsub_topic" "default-telemetry" {
  name = "default-telemetry"
  project = google_project.iot-project.project_id
}

resource "google_project_service" "cloudiot" {
  project = google_project.iot-project.project_id
  service = "cloudiot.googleapis.com"

  disable_dependent_services = true
}

resource "google_cloudiot_registry" "test-registry" {
  name     = "cloudiot-registry"
  project = google_project.iot-project.project_id
  region = "us-central1"

  event_notification_configs {
    pubsub_topic_name = google_pubsub_topic.default-telemetry.id
    subfolder_matches = ""
  }

    mqtt_config = {
    mqtt_enabled_state = "MQTT_ENABLED"
  }

  http_config = {
    http_enabled_state = "HTTP_ENABLED"
  }

  depends_on = [google_project_service.cloudiot]

}