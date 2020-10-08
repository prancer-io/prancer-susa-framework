data "azurerm_app_service_plan" "app_plan" {
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group
}

data "azurerm_private_endpoint_connection" "sql_endpoint" {
  name                = var.sql_endpoint
  resource_group_name = var.resource_group
}

data "azurerm_private_endpoint_connection" "kv_endpoint" {
  name                = var.keyvault_endpoint
  resource_group_name = var.resource_group
}

resource "azurerm_app_service" "app" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group
  app_service_plan_id = data.azurerm_app_service_plan.app_plan.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
    min_tls_version          = "1.2"
  }

  identity {
    type = "SystemAssigned"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=${data.azurerm_private_endpoint_connection.sql_endpoint.private_service_connection.0.private_ip_address};Integrated Security=SSPI"
  }
}
