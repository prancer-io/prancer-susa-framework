variable "name" {}
variable "cidr" {}
variable "azs" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "enable_nat_gateway" {}
variable "enable_vpn_gateway" {}

variable "tags" {
  type = map
  default = {}
}
