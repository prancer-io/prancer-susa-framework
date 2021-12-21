module "app_service_plan" {
  source              = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/appServicePlan/"
  appserviceplan_name = var.app_service_plan_name
  location            = var.location
  appservice_rg       = var.resource_group
  appservice_kind     = var.app_service_plan_kind
  appservice_tier     = var.app_service_plan_tier
  appservice_size     = var.app_service_plan_size
  capacity            = var.app_service_plan_capacity
  tags                = var.tags
}

data "azurerm_private_endpoint_connection" "sql_endpoint" {
  name                = var.sql_endpoint
  resource_group_name = var.resource_group
}

data "azurerm_private_endpoint_connection" "kv_endpoint" {
  name                = var.keyvault_endpoint
  resource_group_name = var.resource_group
}

module "app_service" {
  source              = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/appService/"
  appservice_name     = var.app_service_name
  location            = var.location
  appservice_rg       = var.resource_group
  appserviceplan_name = module.app_service_plan.id
  identity_type       = var.app_service_identity_type
  tags                = var.tags
  conn_name           = "Database"
  conn_type           = "SQLServer"
  conn_value          = "Server=${data.azurerm_private_endpoint_connection.sql_endpoint.private_service_connection.0.private_ip_address};Integrated Security=SSPI"
}
