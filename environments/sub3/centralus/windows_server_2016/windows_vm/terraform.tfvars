vm_name              = "win2016"
vm_rg                = "company-win16-rg"
location             = "centralus"
vm_size              = "Standard_F2"
vm_availability_set  = "win16-avs"
vm_admin_user        = "adminuser"
vm_admin_pass        = "ooP@$$w0rd1234!oo"
vm_interfaces        = ["win16-nic"]
vm_disk_caching      = "ReadWrite"
vm_disk_storage_type = "Standard_LRS"
vm_img_publisher     = "MicrosoftWindowsServer"
vm_img_offer         = "WindowsServer"
vm_img_sku           = "2016-Datacenter"
vm_img_version       = "latest"
