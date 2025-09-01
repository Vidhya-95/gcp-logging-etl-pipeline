output "topic_name" {
  value = google_pubsub_topic.tf_topic.name
}

output "logging_sink_name" {
  value = google_logging_project_sink.tf_topic_sink.name
}

output "bucket_name" {
  value = google_storage_bucket.tf_bucket.name
}

output "object_name" {
  value = google_storage_bucket_object.tf_object.name
}

output "function_name" {
  value = google_cloudfunctions2_function.tf_process_audit_logs_func.name
}

output "function_event_trigger_topic" {
  value = google_cloudfunctions2_function.tf_process_audit_logs_func.event_trigger[0].pubsub_topic
}
