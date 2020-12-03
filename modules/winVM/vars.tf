variable "vm_name" {
  description = "The name of the Windows Virtual Machine. Changing this forces a new resource to be created."
}

variable "vm_rg" {
  description = "The name of the Resource Group in which the Windows Virtual Machine should be exist."
}

variable "location" {
  description = "The Azure location where the Windows Virtual Machine should exist."
}

variable "vm_size" {
  description = "The SKU which should be used for this Virtual Machine, such as Standard_F2."
}

variable "vm_availability_set_id" {
  description = "Specifies the ID of the Availability Set in which the Virtual Machine should exist."
}

variable "vm_admin_user" {
  description = "The username of the local administrator used for the Virtual Machine."
}

variable "vm_admin_pass" {
  description = "The Password which should be used for the local-administrator on this Virtual Machine."
}

variable "vm_interfaces" {
  description = "A list of Network Interface ID's which should be attached to this Virtual Machine."
  type = list
}

variable "vm_disk_caching" {
  description = "The Type of Caching which should be used for the Internal OS Disk. Possible values are None, ReadOnly and ReadWrite."
}

variable "vm_disk_storage_type" {
  description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values are Standard_LRS, StandardSSD_LRS and Premium_LRS."
}

variable "vm_img_publisher" {
  description = "Specifies the publisher of the image used to create the virtual machines."
}

variable "vm_img_offer" {
  description = "Specifies the offer of the image used to create the virtual machines."
}

variable "vm_img_sku" {
  description = "Specifies the SKU of the image used to create the virtual machines."
}

variable "vm_img_version" {
  description = "Specifies the version of the image used to create the virtual machines."
}

variable "storage_account_uri"{
  description = "The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor."
}
