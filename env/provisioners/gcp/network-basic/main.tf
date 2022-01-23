module "network" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "4.0.1"

  project_id      = var.project_id
  network_name    = var.network_name

  auto_create_subnetworks = var.auto_create_subnetworks
}
