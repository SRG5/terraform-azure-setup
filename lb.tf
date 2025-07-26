# Public IP עבור Load Balancer
resource "azurerm_public_ip" "lb_pip" {
  name                = "cloudphoto-lb-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Basic"
}

# Load Balancer
resource "azurerm_lb" "app_lb" {
  name                = "cloudphoto-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "PublicFrontend"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

# Backend Pool
resource "azurerm_lb_backend_address_pool" "app_lb_backend" {
  name                = "backend-pool"
  loadbalancer_id     = azurerm_lb.app_lb.id
}

# Health Probe ל־8080
resource "azurerm_lb_probe" "app_lb_probe" {
  name                = "flask-health-probe"
  loadbalancer_id     = azurerm_lb.app_lb.id
  protocol            = "Tcp"
  port                = 8080
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Rule שמעביר HTTP → Flask
resource "azurerm_lb_rule" "app_lb_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.app_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicFrontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_lb_backend.id]
  probe_id                       = azurerm_lb_probe.app_lb_probe.id
}

# קישור NIC ל־Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "web_nic_to_lb" {
  network_interface_id    = azurerm_network_interface.web_nic.id
  ip_configuration_name   = "web-ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.app_lb_backend.id
}
