vnet_name               = "company-app-vnet"
subnet_name             = "company-app-subnet"
subnet_address_prefixes = ["10.0.10.0/24"]
resource_group = "company-app-rg"

tags = {
  environment = "Production"
  project     = "company App"
}
