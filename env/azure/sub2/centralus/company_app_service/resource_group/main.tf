module "resource_group" {
  source   = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/resourceGroup"
  name     = var.resource_group
  location = var.location

  tags     = var.tags
}
