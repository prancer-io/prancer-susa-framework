module "vnet" {
  source                = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/virtualNetwork/"
  location              = var.location
  vnet_name             = var.vnet_name
  vnet_rg               = var.resource_group
  address_space         = var.vnet_address_space
  dns_server            = var.vnet_dns_servers
  tags                  = {}
}
