terraform {
  backend "azurerm" {
    storage_account_name = "str001"
    container_name       = "states"
    key                  = ""
    access_key           = ""
  }
}
