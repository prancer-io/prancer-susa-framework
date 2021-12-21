terraform {
  backend "azurerm" {
    storage_account_name = "azrcterrafstr10"
    container_name       = "states"
    key                  = "azure/sub2/centralus/company_app_service/resource_group/terraform.tfstate"
    access_key           = ""
  }
}
