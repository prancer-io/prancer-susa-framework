terraform {
  backend "azurerm" {
    storage_account_name = "azrcterrafstr10"
    container_name       = "states"
    key                  = "azure/sub3/centralus/windows_server_2016/resource_group/terraform.tfstate"
    access_key           = ""
  }
}
