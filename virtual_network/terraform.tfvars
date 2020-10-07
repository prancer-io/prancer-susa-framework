vnet_name               = "prancer-app-vnet"
vnet_address_space      = ["10.0.0.0/16"]
vnet_dns_servers        = ["10.0.0.4", "10.0.0.5"]
resource_group = "prancer-app-rg"
location       = "eastus2"

tags = {
  environment = "Production"
  project     = "Prancer App"
}
