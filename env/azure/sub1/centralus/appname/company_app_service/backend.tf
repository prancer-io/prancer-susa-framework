terraform {
  backend "azurerm" {
    storage_account_name = "azrcterrafstr10"
    container_name       = "states"
    key                  = "azure/sub1/centralus/appname/company_app_service/terraform.tfstate"
    access_key           = ""
  }
}
