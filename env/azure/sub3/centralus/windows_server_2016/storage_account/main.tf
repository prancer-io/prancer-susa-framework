module "storage_account" {
  source                = "git::ssh://git@github.com/prancer-io/prancer-terraform-modules//azure/storageAccount/"
  storage_count         = var.storage_count
  storage_name          = var.storage_name
  storage_rg_name       = var.storage_rg_name
  location              = var.location
  accountTier           = var.accountTier
  replicationType       = var.replicationType
  enableSecureTransfer  = var.enableSecureTransfer
  tags                  = var.tags
}
