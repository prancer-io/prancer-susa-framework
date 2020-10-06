resource "azurerm_sql_server" "sql" {
  name                         = "prancer-sql-server"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "dbadmin"
  administrator_login_password = "E36b4fcf15bc3c0e0439d67846b3f9!7"
}

resource "azurerm_sql_database" "sql_db" {
  name                             = "prancer-sql-db"
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  server_name                      = azurerm_sql_server.sql.name
  edition                          = "Standard"

  tags = var.tags
}

resource "azurerm_private_endpoint" "sql_endpoint" {
  name                = "prancer-sql-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_subnet.subnet.resource_group_name
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {

    name                           = "prancer-sql-private-endpoint"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_sql_server.sql.id
    subresource_names              = ["sqlServer"]
  }
}
