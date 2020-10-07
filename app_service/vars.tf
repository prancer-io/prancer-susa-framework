variable "app_service_name" {}

variable "app_service_plan_name" {}
variable "app_service_plan_tier" {}
variable "app_service_plan_size" {}

variable "sql_name" {}
variable "sql_version" {}
variable "sql_username" {}
variable "sql_password" {}
variable "sql_db_name" {}
variable "sql_endpoint" {}
variable "sql_connection" {}

variable "keyvault_name" {}
variable "keyvault_sku" {}
variable "keyvault_endpoint" {}
variable "keyvault_connection" {}

variable "vnet_name" {}
variable "vnet_address_space" {}
variable "vnet_dns_servers" {}
variable "subnet_name" {}
variable "subnet_address_prefixes" {}

variable "resource_group" {}
variable "location" {}

variable "tags" {
  type    = map
  default = {}
}
