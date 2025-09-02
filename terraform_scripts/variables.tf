variable "project_id" {
  default     = "<PROJECT_ID>" #Add your desired project id.
  description = "This a GCP Project Id"
}

variable "topic_name" {
  default     = "tf-audit-logs"
  description = "This a topic name"
}

variable "logging_sink_name" {
  default     = "tf-audit-log-sink"
  description = "This a name for logging sink"
}

variable "bucket_name" {
  default = "tf_gcf-source"
  description = "Bucket name to store the source code"
}

variable "bucket_location" {
  default = "US"
  description = "Value for the bucket location"
}

variable "object_name" {
  default = "tf_process_audit_logs_function-source.zip"
  description = "Value for the object name"
}

variable "function_name" {
  default = "tf_process_audit_logs"
  description = "Name of the function to process audit logs"
}

variable "function_location" {
  default = "us-central1"
  description = "Location of the function"
}
