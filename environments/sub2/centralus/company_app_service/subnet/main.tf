
module "subnet" {
  source                = "../../../../../modules/subnet/"
  subnet_name           = var.subnet_name
  subnet_rg             = var.resource_group
  vnet_name             = var.vnet_name
  address_prefixes      = var.subnet_address_prefixes
  service_endpoints     = var.subnet_service_endpoints
  enforce_private_link  = var.subnet_enforce_private_link
}
