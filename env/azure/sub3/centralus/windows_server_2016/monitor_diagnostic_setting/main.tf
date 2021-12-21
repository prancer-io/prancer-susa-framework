data "azurerm_virtual_machine" "win16vm" {
  name                = var.vm_name
  resource_group_name = var.vm_rg
}

data "azurerm_storage_account" "diagnostics" {
  name                = var.mds_storage_account
  resource_group_name = var.vm_rg
}

module "monitor_diagnostic_setting" {
  source                   = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/monitorDiagnostics/"
  mds_name                 = var.mds_name
  mds_resource_id          = data.azurerm_virtual_machine.win16vm.id
  mds_storage_account      = data.azurerm_storage_account.diagnostics.id
  diagnostics_log          = var.diagnostics_log
  log_retention_policy     = var.log_retention_policy
  metric_category          = var.metric_category
  metrics_retention_policy = var.metrics_retention_policy
}
