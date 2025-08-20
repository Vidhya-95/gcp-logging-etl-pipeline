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