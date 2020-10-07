keyvault_name       = "prancer-key-vault"
keyvault_sku        = "standard"
keyvault_endpoint   = "prancer-kv-endpoint"
keyvault_connection = "prancer-kv-connection"
vnet_name               = "prancer-app-vnet"
subnet_name             = "prancer-app-subnet"
resource_group = "prancer-app-rg"
location       = "eastus2"

tags = {
  environment = "Production"
  project     = "Prancer App"
}
