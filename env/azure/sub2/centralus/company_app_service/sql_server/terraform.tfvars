sql_name        = "company-sql-server"
sql_version     = "12.0"
sql_username    = "dbadmin"
sql_password    = "E36b4fcf15bc3c0e0439d67846b3f9!7"
sql_endpoint    = "company-sql-endpoint"
sql_connection  = "company-sql-connection"
sql_subresource = ["sqlServer"]
vnet_name       = "company-app-vnet"
subnet_name     = "company-app-subnet"

resource_group = "company-app-rg"
location       = "centralus"

tags = {
  environment = "Production"
  project     = "company App"
}
