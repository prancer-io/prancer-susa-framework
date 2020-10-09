variable "location" {
  description = "The location/region where resource will be created. Changing this forces a new resource to be created."
}

variable "appservice_rg" {
  description = "The name of the resource group in which to create the App Service Plan component."
}

variable "appserviceplan_name" {
  description = "Specifies the name of the App Service Plan component. Changing this forces a new resource to be created"
}

variable "appservice_size" {
  description = "Specifies the plan's instance size."
}

variable "appservice_tier" {
  description = "Specifies the plan's pricing tier."
}

variable "appservice_kind" {
  description = "The kind of the App Service Plan to create. Possible values are Windows (also available as App), Linux and FunctionApp (for a Consumption Plan). Defaults to Windows. Changing this forces a new resource to be created."
}

variable "capacity" {
  description = "(Optional) Specifies the number of workers associated with this App Service Plan."
}

variable tags {
  type = map
}
