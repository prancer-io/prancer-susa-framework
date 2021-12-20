module "key_vault" {
  source                    = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/keyVault/"
  name                      = var.keyvault_name
  location                  = var.location
  resourceGroup             = var.resource_group
  skuname                   = var.keyvault_sku
  tags                      = var.tags
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group
}

module "kv_endpoint" {
  source                         = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/privateEndpoint/"
  name                           = var.keyvault_endpoint
  location                       = var.location
  resource_group_name            = var.resource_group
  subnet_id                      = data.azurerm_subnet.subnet.id
  connection_name                = var.keyvault_connection
  private_connection_resource_id = module.key_vault.vault_Id
  subresource_names              = var.keyvault_subresource
}
