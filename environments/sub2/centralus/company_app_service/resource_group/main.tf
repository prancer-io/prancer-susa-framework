module "resource_group" {
  source   = "../../../../../modules/resourceGroup"
  name     = var.resource_group
  location = var.location

  tags     = var.tags
}
