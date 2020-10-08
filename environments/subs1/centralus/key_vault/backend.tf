terraform {
  backend "azurerm" {
    storage_account_name = "azrcterrafstr10"
    container_name       = "states"
    key                  = "subs1/centralus/key_vault/terraform.tfstate"
    access_key           = ""
  }
}
