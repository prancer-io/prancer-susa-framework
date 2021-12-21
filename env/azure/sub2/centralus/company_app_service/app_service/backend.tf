terraform {
  backend "azurerm" {
    storage_account_name = "azrcterrafstr10"
    container_name       = "states"
    key                  = "sub2/centralus/company_app_service/app_service/terraform.tfstate"
    access_key           = ""
  }
}
