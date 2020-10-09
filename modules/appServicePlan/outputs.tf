output "id" {
  value = azurerm_app_service_plan.appservice.id
}

output "name" {
  value = azurerm_app_service_plan.appservice.name
}

output "maxworkersupported" {
  value = azurerm_app_service_plan.appservice.maximum_number_of_workers
}
