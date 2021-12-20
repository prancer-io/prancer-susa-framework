keyvault_name        = "company-keyvault-store"
keyvault_sku         = "standard"
keyvault_endpoint    = "company-kv-endpoint"
keyvault_connection  = "company-kv-connection"
keyvault_subresource = ["Vault"]
vnet_name            = "company-app-vnet"
subnet_name          = "company-app-subnet"
resource_group       = "company-app-rg"
location             = "centralus"
tags                 = {
  environment = "Production"
  project     = "company App"
}
