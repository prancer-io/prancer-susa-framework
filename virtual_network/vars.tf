variable "vnet_name" {}
variable "vnet_address_space" {}
variable "vnet_dns_servers" {}
variable "resource_group" {}
variable "location" {}

variable "tags" {
  type    = map
  default = {}
}
