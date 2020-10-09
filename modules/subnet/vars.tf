variable "subnet_name" {
  description = "The name of the subnet. Changing this forces a new resource to be created."
}

variable "subnet_rg" {
  description = "The name of the resource group in which to create the subnet. Changing this forces a new resource to be created."
}

variable "vnet_name" {
  description = "The name of the virtual network to which to attach the subnet. Changing this forces a new resource to be created."
}

variable "address_prefixes" {
  description = "The address prefix to use for the subnet."
}

variable "service_endpoints" {
  description = "The list of Service endpoints to associate with the subnet."
  type = list
  default = []
}

variable "enforce_private_link" {
  description = "Enable or Disable network policies for the private link endpoint on the subnet."
  default = false
}
