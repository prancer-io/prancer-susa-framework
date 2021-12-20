vnet_name                   = "company-app-vnet"
subnet_name                 = "company-app-subnet"
subnet_address_prefixes     = ["10.0.10.0/24"]
subnet_service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Sql"]
subnet_enforce_private_link = true
resource_group = "company-app-rg"
location       = "centralus"
