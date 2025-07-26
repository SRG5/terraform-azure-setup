output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "db_private_ip" {
  value       = azurerm_network_interface.db_nic.private_ip_address
  description = "The private IP address of the DB server"
}

output "photo_url" {
  value       = "https://${azurerm_storage_account.photo_storage.name}.blob.core.windows.net/${azurerm_storage_container.photo_container.name}/${azurerm_storage_blob.sample_image.name}"
  description = "Direct link to the uploaded photo in Azure Blob Storage"
}

output "load_balancer_ip" {
  value       = azurerm_public_ip.lb_pip.ip_address
  description = "The public IP address of the Load Balancer"
}

output "health_check_url" {
  value       = "http://${azurerm_public_ip.lb_pip.ip_address}/healthz"
  description = "Health check endpoint for Flask app through Load Balancer"
}

output "app_url" {
  value       = "http://${azurerm_public_ip.lb_pip.ip_address}/image"
  description = "Main image endpoint of the application"
}

output "add_record_url_example" {
  value       = "http://${azurerm_public_ip.lb_pip.ip_address}/add?name=Baruchi&value=87&time=Wed Jun 28 18:05:52 UTC 2023"
  description = "Example usage of the /add endpoint with query parameters"
}

output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.web_vmss.name
}
