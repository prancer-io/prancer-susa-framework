terraform {
  backend "azurerm" {
    storage_account_name = "azrcterrafstr10"
    container_name       = "states"
    key                  = "subs1/centralus/app_service_plan/terraform.tfstate"
    access_key           = ""
  }
}
