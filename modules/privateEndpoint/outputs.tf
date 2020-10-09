output "fqdn" {
  value = azurerm_private_endpoint.private_endpoint.custom_dns_configs.0.fqdn
}
