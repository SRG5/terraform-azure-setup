resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                = "cloudphoto-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name
  upgrade_mode        = "Manual"
  sku                 = "Standard_B1ms"
  instances           = 1
  admin_username      = var.admin_username

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "web-nic"
    primary = true

    ip_configuration {
      name                                   = "web-ipconfig"
      primary                                = true
      subnet_id                              = azurerm_subnet.web_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.app_lb_backend.id]
    }
  }

  custom_data = filebase64("cloud-init-web.yaml")

  # health_probe_id = azurerm_lb_probe.app_lb_probe.id
  computer_name_prefix = "cloudphoto"
  overprovision = false
}
