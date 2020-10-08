variable "vnet_name" {}
variable "subnet_name" {}
variable "subnet_address_prefixes" {}
variable "resource_group" {}

variable "tags" {
  type    = map
  default = {}
}
