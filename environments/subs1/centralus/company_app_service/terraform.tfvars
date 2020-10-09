app_service_name = "company-app-service"

app_service_plan_name     = "company-app-plan"
app_service_plan_kind     = "App"
app_service_plan_tier     = "Standard"
app_service_plan_size     = "S1"
app_service_plan_capacity = 2

sql_name        = "company-sql-server"
sql_version     = "12.0"
sql_username    = "dbadmin"
sql_password    = "E36b4fcf15bc3c0e0439d67846b3f9!7"
sql_endpoint    = "company-sql-endpoint"
sql_connection  = "company-sql-connection"
sql_subresource = ["sqlServer"]

keyvault_name        = "company-keyvault-store"
keyvault_sku         = "standard"
keyvault_endpoint    = "company-kv-endpoint"
keyvault_connection  = "company-kv-connection"
keyvault_subresource = ["Vault"]

vnet_name                   = "company-app-vnet"
vnet_address_space          = "10.0.0.0/16"
vnet_dns_servers            = ["10.0.0.4", "10.0.0.5"]
subnet_name                 = "company-app-subnet"
subnet_address_prefixes     = ["10.0.10.0/24"]
subnet_service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Sql"]
subnet_enforce_private_link = true

resource_group = "company-app-rg"
location       = "centralus"

tags = {
  environment = "Production"
  project     = "company App"
}
