output "topic_name" {
  value = google_pubsub_topic.tf_topic.name
}

output "logging_sink_name" {
  value = google_logging_project_sink.tf_topic_sink.name
}