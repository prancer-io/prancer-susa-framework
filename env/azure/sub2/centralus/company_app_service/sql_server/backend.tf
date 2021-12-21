terraform {
  backend "azurerm" {
    storage_account_name = "azrcterrafstr10"
    container_name       = "states"
    key                  = "azure/sub2/centralus/company_app_service/sql_server/terraform.tfstate"
    access_key           = "bmkDv5TJ5Wn5TdvVTeRN2OymI4/lMoCvKVeepmFXMCOgZzRPn+rFR+wQwXkCvyEJNbaHZ5Z8bzRd66nIM6hvRQ=="
  }
}
