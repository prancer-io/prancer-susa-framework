resource "azurerm_sql_server" "sql" {
  name                         = var.sql_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = var.sql_version
  administrator_login          = var.sql_username
  administrator_login_password = var.sql_password
}

resource "azurerm_sql_database" "sql_db" {
  name                             = var.sql_db_name
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  server_name                      = azurerm_sql_server.sql.name
  edition                          = "Standard"

  tags = var.tags
}

resource "azurerm_private_endpoint" "sql_endpoint" {
  name                = var.sql_endpoint
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_subnet.subnet.resource_group_name
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {

    name                           = var.sql_connection
    is_manual_connection           = false
    private_connection_resource_id = azurerm_sql_server.sql.id
    subresource_names              = ["sqlServer"]
  }
}
