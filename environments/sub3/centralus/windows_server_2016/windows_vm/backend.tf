terraform {
  backend "azurerm" {
    storage_account_name = "azrcterrafstr10"
    container_name       = "states"
    key                  = "sub3/centralus/windows_server_2016/windows_vm/terraform.tfstate"
    access_key           = "bmkDv5TJ5Wn5TdvVTeRN2OymI4/lMoCvKVeepmFXMCOgZzRPn+rFR+wQwXkCvyEJNbaHZ5Z8bzRd66nIM6hvRQ=="
  }
}
