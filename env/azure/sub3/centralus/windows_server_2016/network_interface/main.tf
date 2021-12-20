data "azurerm_subnet" "subnet" {
  name                 = var.ipconf_subnet
  virtual_network_name = var.ipconf_vnet
  resource_group_name  = var.nic_rg
}

module "network_interface" {
  source            = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//modules/netInterface/"
  nic_name          = var.nic_name
  location          = var.location
  nic_rg            = var.nic_rg
  ipconf_name       = var.ipconf_name
  ipconf_subnet     = data.azurerm_subnet.subnet.id
  ipconf_allocation = var.ipconf_allocation
}
