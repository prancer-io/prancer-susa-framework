vnet_name               = "company-app-vnet"
vnet_address_space      = ["10.0.0.0/16"]
vnet_dns_servers        = ["10.0.0.4", "10.0.0.5"]
resource_group = "company-app-rg"
location       = "centralus"

tags = {
  environment = "Production"
  project     = "company App"
}
