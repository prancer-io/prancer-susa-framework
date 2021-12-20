module "sql_server" {
  source                    = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//modules/sqlServer/"
  location                  = var.location
  server_name               = var.sql_name
  server_rg                 = var.resource_group
  server_version            = var.sql_version
  admin_user                = var.sql_username
  admin_password            = var.sql_password
  tags                      = var.tags
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group
}

module "sql_endpoint" {
  source                         = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//modules/privateEndpoint/"
  name                           = var.sql_endpoint
  location                       = var.location
  resource_group_name            = var.resource_group
  subnet_id                      = data.azurerm_subnet.subnet.id
  connection_name                = var.sql_connection
  private_connection_resource_id = module.sql_server.sqlserver_id
  subresource_names              = var.sql_subresource
}
