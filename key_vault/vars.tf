variable "keyvault_name" {}
variable "keyvault_sku" {}
variable "keyvault_endpoint" {}
variable "keyvault_connection" {}
variable "vnet_name" {}
variable "subnet_name" {}
variable "resource_group" {}
variable "location" {}

variable "tags" {
  type    = map
  default = {}
}
