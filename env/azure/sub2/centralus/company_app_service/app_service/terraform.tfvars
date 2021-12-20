app_service_name          = "company-app-service"
app_service_identity_type = "SystemAssigned"
app_service_plan_name     = "company-app-plan"
app_service_plan_kind     = "App"
app_service_plan_tier     = "Standard"
app_service_plan_size     = "S1"
app_service_plan_capacity = 2
sql_endpoint    = "company-sql-endpoint"
keyvault_endpoint    = "company-kv-endpoint"
resource_group = "company-app-rg"
location       = "centralus"
tags = {
  environment = "Production"
  project     = "company App"
}
