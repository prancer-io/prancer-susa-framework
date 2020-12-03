variable mds_name {
  description = "Specifies the name of the Diagnostic Setting."
}

variable mds_resource_id {
  description = "The ID of an existing Resource on which to configure Diagnostic Settings."
}

variable mds_storage_account {
  description = "The ID of the Storage Account where logs should be sent."
}

variable diagnostics_log {
  description = "The name of a Diagnostic Log Category for this Resource."
  type = list
}

variable log_retention_policy {
  description = "Is Log Retention Policy enabled?"
}

variable metric_category {
  description = "The name of a Diagnostic Metric Category for this Resource."
}

variable metrics_retention_policy {
  description = "Is Metrics Retention Policy enabled?"
}
