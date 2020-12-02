resource "azurerm_windows_virtual_machine" "winvm" {
  name                  = var.vm_name
  resource_group_name   = var.vm_rg
  location              = var.location
  size                  = var.vm_size
  availability_set_id   = var.vm_availability_set_id
  admin_username        = var.vm_admin_user
  admin_password        = var.vm_admin_pass
  network_interface_ids = var.vm_interfaces

  os_disk {
    caching              = var.vm_disk_caching
    storage_account_type = var.vm_disk_storage_type
  }

  source_image_reference {
    publisher = var.vm_img_publisher
    offer     = var.vm_img_offer
    sku       = var.vm_img_sku
    version   = var.vm_img_version
  }
}
