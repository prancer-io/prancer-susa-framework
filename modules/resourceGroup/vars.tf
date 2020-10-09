variable "location" {
  description = "Azure region to use"
  type        = string
}

variable "name" {
  description = "Resource group name"
  type        = string
  default     = ""
}

variable "tags" {
  description = "tags to add"
  type        = map(string)
  default     = {}
}
