data "azurerm_network_interface" "network_interface" {
  name                = var.vm_interfaces[0]
  resource_group_name = var.vm_rg
}

data "azurerm_availability_set" "availability_set" {
  name                = var.vm_availability_set
  resource_group_name = var.vm_rg
}

module "winvm" {
  source                 = "../../../../../modules/winVM/"
  vm_name                = var.vm_name
  vm_rg                  = var.vm_rg
  location               = var.location
  vm_size                = var.vm_size
  vm_availability_set_id = data.azurerm_availability_seta.vailability_set.id
  vm_admin_user          = var.vm_admin_user
  vm_admin_pass          = var.vm_admin_pass
  vm_interfaces          = [data.azurerm_network_interface.network_interface.id]
  vm_disk_caching        = var.vm_disk_caching
  vm_disk_storage_type   = var.vm_disk_storage_type
  vm_img_publisher       = var.vm_img_publisher
  vm_img_offer           = var.vm_img_offer
  vm_img_sku             = var.vm_img_sku
  vm_img_version         = var.vm_img_version
}
