locals {
  project_id = var.project_id
}

variable "project_id" {
  default     = "rich-chimera-462008-v9"
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

