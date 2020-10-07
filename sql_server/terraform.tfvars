sql_name       = "prancer-sql-server"
sql_version    = "12.0"
sql_username   = "dbadmin"
sql_password   = "E36b4fcf15bc3c0e0439d67846b3f9!7"
sql_db_name    = "prancer-sql-db"
sql_endpoint   = "prancer-sql-endpoint"
sql_connection = "prancer-sql-connection"
vnet_name               = "prancer-app-vnet"
subnet_name             = "prancer-app-subnet"
resource_group = "prancer-app-rg"
location       = "eastus2"

tags = {
  environment = "Production"
  project     = "Prancer App"
}
