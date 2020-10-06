data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "prancer-key-vault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "kv_endpoint" {
  name                = "prancer-kv-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_subnet.subnet.resource_group_name
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {

    name                           = "prancer-kv-private-endpoint"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["Vault"]
  }
}
