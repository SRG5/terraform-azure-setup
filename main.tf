provider "azurerm" {
  features {}
  subscription_id                 = "a336c49a-857d-4721-a0bc-815981f9839a"
  tenant_id                       = "8295a129-7c77-4f35-9ea4-2921d9019a4d"
  use_cli                         = true
  resource_provider_registrations = "none"
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# VNet
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Subnet for Web
resource "azurerm_subnet" "web_subnet" {
  name                 = var.web_subnet_name
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.web_subnet_prefix
}

# NSG for web
resource "azurerm_network_security_group" "web_nsg" {
  name                = "simple-net-web-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # פתיחה ל-Load Balancer
  security_rule {
    name                       = "AllowHTTPFromAzureLB"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# קשר NSG ל־Web Subnet
resource "azurerm_subnet_network_security_group_association" "web_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.web_subnet.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# Public IP
# resource "azurerm_public_ip" "pip" {
#   name                = "simple-net-pip"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   allocation_method   = "Static"
#   sku                 = "Basic"
#  }

# NIC for web
resource "azurerm_network_interface" "web_nic" {
  name                = "simple-net-web-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "web-ipconfig"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.4"
    # public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Web VM
# resource "azurerm_linux_virtual_machine" "web" {
#   name                = var.web_vm_name
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   size                = "Standard_B1s"
#   admin_username      = var.admin_username
#
#   network_interface_ids = [
#     azurerm_network_interface.web_nic.id
#   ]

#   admin_ssh_key {
#     username   = var.admin_username
#     public_key = var.ssh_public_key
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

#   custom_data = filebase64("cloud-init-web.yaml")
# }
