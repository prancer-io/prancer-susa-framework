variable "sql_name" {}
variable "sql_version" {}
variable "sql_username" {}
variable "sql_password" {}
variable "sql_db_name" {}
variable "sql_endpoint" {}
variable "sql_connection" {}
variable "vnet_name" {}
variable "subnet_name" {}
variable "resource_group" {}
variable "location" {}

variable "tags" {
  type    = map
  default = {}
}
