resource "azurerm_monitor_diagnostic_setting" "mds" {
  name               = var.mds_name
  target_resource_id = var.mds_resource_id
  storage_account_id = var.mds_storage_account


  dynamic "log" {
    for_each = var.diagnostics_log

    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = var.log_retention_policy
      }
    }
  }

  metric {
    category = var.metric_category

    retention_policy {
      enabled = var.metrics_retention_policy
    }
  }
}
