app_service_name = "prancer-app-service"

app_service_plan_name = "prancer-app-plan"
app_service_plan_tier = "Standard"
app_service_plan_size = "S1"

sql_name       = "prancer-sql-server"
sql_version    = "12.0"
sql_username   = "dbadmin"
sql_password   = "E36b4fcf15bc3c0e0439d67846b3f9!7"
sql_db_name    = "prancer-sql-db"
sql_endpoint   = "prancer-sql-endpoint"
sql_connection = "prancer-sql-connection"

keyvault_name       = "prancer-key-vault"
keyvault_sku        = "standard"
keyvault_endpoint   = "prancer-kv-endpoint"
keyvault_connection = "prancer-kv-connection"

vnet_name               = "prancer-app-vnet"
vnet_address_space      = ["10.0.0.0/16"]
vnet_dns_servers        = ["10.0.0.4", "10.0.0.5"]
subnet_name             = "prancer-app-subnet"
subnet_address_prefixes = ["10.0.10.0/24"]

resource_group = "prancer-app-rg"
location       = "eastus2"

tags = {
  environment = "Production"
  project     = "Prancer App"
}
