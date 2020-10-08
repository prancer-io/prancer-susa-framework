keyvault_name       = "company-key-vault"
keyvault_sku        = "standard"
keyvault_endpoint   = "company-kv-endpoint"
keyvault_connection = "company-kv-connection"
vnet_name               = "company-app-vnet"
subnet_name             = "company-app-subnet"
resource_group = "company-app-rg"
location       = "eastus2"

tags = {
  environment = "Production"
  project     = "company App"
}
