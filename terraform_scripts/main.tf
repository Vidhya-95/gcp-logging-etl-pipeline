resource "google_pubsub_topic" "tf_topic" {
  project = var.project_id
  name    = var.topic_name
}

resource "google_logging_project_sink" "tf_topic_sink" {
  name                   = var.logging_sink_name
  destination            = "pubsub.googleapis.com/projects/${var.project_id}/topics/${var.topic_name}"
  filter                 = <<EOT
logName="projects/${var.project_id}/logs/cloudaudit.googleapis.com%2Factivity" 
AND protoPayload.methodName:("create" OR "delete" OR "insert") 
AND operation.last="true"
EOT
  unique_writer_identity = true
}

resource "google_storage_bucket" "tf_bucket" {
  name                        = "${var.project_id}-${var.bucket_name}"
  location                    = var.bucket_location
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "tf_object" {
  name   = var.object_name
  bucket = google_storage_bucket.tf_bucket.name
  source = "<PATH_TO_ZIPPED_SOURCE_CODE>" # Add path to the zipped function source code e.g.: "/gcp-error-etl-pipeline/process_audit_logs_function-source.zip"
}

resource "google_cloudfunctions2_function" "tf_process_audit_logs_func" {
  name        = var.function_name
  location    = var.function_location
  description = "Function to process audit logs"

  build_config {
    runtime     = "python313"
    entry_point = "main" # Set the entry point 

    source {
      storage_source {
        bucket = google_storage_bucket.tf_bucket.name
        object = google_storage_bucket_object.tf_object.name
      }
    }
  }

  event_trigger {
    trigger_region = var.event_trigger_region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.tf_topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}
