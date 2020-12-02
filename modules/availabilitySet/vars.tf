variable "location" {
  description = "The location/region where availability set will be created. Changing this forces a new resource to be created."
}

variable "av_rg_name" {
  description = "The name of the resource group in which the availability set will be created."
}

variable "av_set_name" {
  description = "Custom name provided to availability set created."
}

variable "av_set_managed" {
  description = " Specifies whether the availability set is managed or not."
}

variable "platform_update_domain_count" {
  description = "Specifies the number of update domains that are used."
}

variable "platform_fault_domain_count" {
  description = "Specifies the number of fault domains that are used."
}

variable tags {
  type = map
}
