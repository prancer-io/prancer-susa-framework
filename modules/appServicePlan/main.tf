resource "azurerm_app_service_plan" "appservice" {
  name                = var.appserviceplan_name
  location            = var.location
  resource_group_name = var.appservice_rg
  kind                = var.appservice_kind

  sku {
    tier     = var.appservice_tier
    size     = var.appservice_size
    capacity = var.capacity
  }

  tags = var.tags
}
