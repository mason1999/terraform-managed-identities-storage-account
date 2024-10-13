output "public_ip_address" {
  value = azurerm_public_ip.example.ip_address
}

output "username" {
  value = azurerm_linux_virtual_machine.example.admin_username
}

output "password" {
  value     = azurerm_linux_virtual_machine.example.admin_password
  sensitive = true
}
