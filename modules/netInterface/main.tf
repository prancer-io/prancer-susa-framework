resource "azurerm_network_interface" "nic" {
  name                            = var.nic_name
  location                        = var.location
  resource_group_name             = var.nic_rg

  ip_configuration {
    name                          = var.ipconf_name
    subnet_id                     = var.ipconf_subnet
    private_ip_address_allocation = var.ipconf_allocation
  }
}
