variable "app_service_plan_name" {}
variable "app_service_plan_tier" {}
variable "app_service_plan_size" {}

variable "app_service_name" {}

variable "tags" {
  type    = map
  default = {}
}
