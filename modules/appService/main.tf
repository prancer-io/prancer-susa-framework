resource "azurerm_app_service" "appservice" {
  name                = var.appservice_name
  location            = var.location
  resource_group_name = var.appservice_rg
  app_service_plan_id = var.appserviceplan_name
  tags                = var.tags

  identity {
    type = var.identity_type
  }

  connection_string {
    name  = var.conn_name
    type  = var.conn_type
    value = var.conn_value
  }
}
