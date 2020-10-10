variable "location" {
  description = "The location/region where resource will be created. Changing this forces a new resource to be created."
}

variable "appservice_rg" {
  description = "The name of the resource group in which to create the App Service Plan component."
}

variable "appservice_name" {
  description = "Specifies the name of the App Service Plan component. Changing this forces a new resource to be created"
}

variable "appserviceplan_name" {
  description = "App service plan under which app service will be created."
}

variable "identity_type" {
  description = "Identity type"
  default = "SystemAssigned"
}

variable "conn_name" {
  description = "The name of the Connection String."
}

variable "conn_type" {
  description = "type of the Connection String. Possible values are APIHub, Custom, DocDb, EventHub, MySQL, NotificationHub, PostgreSQL, RedisCache, ServiceBus, SQLAzure and SQLServer"
}

variable "conn_value" {
  description = "The value for the Connection String."
}

variable tags {
  type = map
}
