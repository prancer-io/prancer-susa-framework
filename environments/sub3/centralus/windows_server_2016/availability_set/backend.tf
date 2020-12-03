terraform {
  backend "azurerm" {
    storage_account_name = "azrcterrafstr10"
    container_name       = "states"
    key                  = "sub3/centralus/windows_server_2016/availability_set/terraform.tfstate"
    access_key           = ""
  }
}