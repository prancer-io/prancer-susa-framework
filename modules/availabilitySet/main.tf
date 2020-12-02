resource "azurerm_availability_set" "avset" {
  name                         = var.av_set_name
  location                     = var.location
  resource_group_name          = var.av_rg_name
  managed                      = var.av_set_managed
  platform_update_domain_count = var.platform_update_domain_count
  platform_fault_domain_count  = var.platform_fault_domain_count
  tags                         = var.tags
}
