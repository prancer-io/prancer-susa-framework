terraform {
  backend "azurerm" {
    storage_account_name = "azrcterrafstr10"
    container_name       = "states"
    key                  = "azure/sub3/centralus/windows_server_2016/subnet/terraform.tfstate"
    access_key           = ""
  }
}
