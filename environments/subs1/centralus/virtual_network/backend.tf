terraform {
  backend "azurerm" {
    storage_account_name = "azrcterrafstr10"
    container_name       = "states"
    key                  = "subs1/centralus/virtual_network/terraform.tfstate"
    access_key           = ""
  }
}
