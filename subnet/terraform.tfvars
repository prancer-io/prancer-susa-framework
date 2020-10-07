vnet_name               = "prancer-app-vnet"
subnet_name             = "prancer-app-subnet"
subnet_address_prefixes = ["10.0.10.0/24"]
resource_group = "prancer-app-rg"

tags = {
  environment = "Production"
  project     = "Prancer App"
}
