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

resource "google_pubsub_subscription" "cli-verification-subscription" {
  name  = "cli-verify"
  project = google_project.iot-project.project_id
  topic = google_pubsub_topic.default-telemetry.name
}

resource "google_pubsub_topic" "state-events" {
  name = "state-events"
  project = google_project.iot-project.project_id
}

resource "google_project_service" "cloudiot" {
  project = google_project.iot-project.project_id
  service = "cloudiot.googleapis.com"

  disable_dependent_services = true
}

resource "google_cloudiot_registry" "cloudiot-registry" {
  name     = "cloudiot-registry"
  project = google_project.iot-project.project_id
  region = var.region

  event_notification_configs {
    pubsub_topic_name = google_pubsub_topic.default-telemetry.id
    subfolder_matches = ""
  }

  state_notification_config = {
    pubsub_topic_name = google_pubsub_topic.state-events.id
  }

  mqtt_config = {
    mqtt_enabled_state = "MQTT_ENABLED"
  }

  http_config = {
    http_enabled_state = "HTTP_ENABLED"
  }

  depends_on = [google_project_service.cloudiot]

}

resource "tls_private_key" "esp32-01" {
  algorithm   = "RSA"
  rsa_bits = 2048
}

resource "google_cloudiot_device" "esp32-device-01" {
  name     = "sparkfun-thing-01"
  registry = google_cloudiot_registry.cloudiot-registry.id

  credentials {
    public_key {
        format = "RSA_PEM"
        key = tls_private_key.esp32-01.public_key_pem
    }
  }
}