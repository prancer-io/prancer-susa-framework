module "availability_set" {
  source                       = "../../../../../modules/availabilitySet/"
  av_set_name                  = var.av_set_name
  location                     = var.location
  av_rg_name                   = var.av_rg_name
  av_set_managed               = var.av_set_managed
  platform_update_domain_count = var.platform_update_domain_count
  platform_fault_domain_count  = var.platform_fault_domain_count
  tags                         = var.tags
}
