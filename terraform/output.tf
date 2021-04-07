output "urclacr" {
    value = azurerm_container_registry.acr.login_server
}

output "adminusername" {
    value = azurerm_container_registry.acr.admin_username
}

output "adminpassword" {
    value = azurerm_container_registry.acr.admin_password
}

