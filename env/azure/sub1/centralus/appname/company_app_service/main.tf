module "resource_group" {
  source   = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/resourceGroup"
  name     = var.resource_group
  location = var.location

  tags     = var.tags
}

module "vnet" {
  source                = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/virtualNetwork/"
  location              = var.location
  vnet_name             = var.vnet_name
  vnet_rg               = module.resource_group.name
  address_space         = var.vnet_address_space
  dns_server            = var.vnet_dns_servers
  tags                  = {}
}

module "subnet" {
  source                = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/subnet/"
  subnet_name           = var.subnet_name
  subnet_rg             = module.resource_group.name
  vnet_name             = module.vnet.vnet_name
  address_prefixes      = var.subnet_address_prefixes
  service_endpoints     = var.subnet_service_endpoints
  enforce_private_link  = var.subnet_enforce_private_link
}

module "sql_server" {
  source                    = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/sqlServer/"
  location                  = var.location
  server_name               = var.sql_name
  server_rg                 = module.resource_group.name
  server_version            = var.sql_version
  admin_user                = var.sql_username
  admin_password            = var.sql_password
  tags                      = var.tags
}

module "sql_endpoint" {
  source                         = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/privateEndpoint/"
  name                           = var.sql_endpoint
  location                       = var.location
  resource_group_name            = module.resource_group.name
  subnet_id                      = module.subnet.subnet_id
  connection_name                = var.sql_connection
  private_connection_resource_id = module.sql_server.sqlserver_id
  subresource_names              = var.sql_subresource
}

module "key_vault" {
  source                    = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/keyVault/"
  name                      = var.keyvault_name
  location                  = var.location
  resourceGroup             = module.resource_group.name
  skuname                   = var.keyvault_sku
  tags                      = var.tags
}

module "kv_endpoint" {
  source                         = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/privateEndpoint/"
  name                           = var.keyvault_endpoint
  location                       = var.location
  resource_group_name            = module.resource_group.name
  subnet_id                      = module.subnet.subnet_id
  connection_name                = var.keyvault_connection
  private_connection_resource_id = module.key_vault.vault_Id
  subresource_names              = var.keyvault_subresource
}

module "app_service_plan" {
  source              = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/appServicePlan/"
  appserviceplan_name = var.app_service_plan_name
  location            = var.location
  appservice_rg       = module.resource_group.name
  appservice_kind     = var.app_service_plan_kind
  appservice_tier     = var.app_service_plan_tier
  appservice_size     = var.app_service_plan_size
  capacity            = var.app_service_plan_capacity
  tags                = var.tags
}

module "app_service" {
  source              = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/appService/"
  appservice_name     = var.app_service_name
  location            = var.location
  appservice_rg       = module.resource_group.name
  appserviceplan_name = module.app_service_plan.id
  tags                = var.tags
  conn_name           = "Database"
  conn_type           = "SQLServer"
  conn_value          = "Server=${module.sql_endpoint.fqdn};Integrated Security=SSPI"
}
