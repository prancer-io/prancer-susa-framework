variable "nic_name" {
  description = "The name of the network interface."
}

variable "location" {
  description = "The name of the resource group in which to create the network interface."
}

variable "nic_rg" {
  description = "The location/region where the network interface is created."
}

variable "ipconf_name" {
  description = "User-defined name of the IP."
}

variable "ipconf_subnet" {
  description = "Reference to a subnet in which this NIC has been created."
}

variable "ipconf_allocation" {
  description = "Defines how a private IP address is assigned. Options are Static or Dynamic."
}
