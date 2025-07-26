# Subnet for DB
resource "azurerm_subnet" "db_subnet" {
  name                 = var.db_subnet_name
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.db_subnet_prefix

  depends_on = [azurerm_virtual_network.vnet]
}

# NSG for DB
resource "azurerm_network_security_group" "db_nsg" {
  name                = "simple-net-db-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowPostgresFromWeb"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.1.1.4" # רק Web
    destination_address_prefix = "*"
    destination_port_range     = "5432"
    source_port_range          = "*"
  }

  security_rule {
    name                       = "AllowSSHFromWeb"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.1.1.4" # רק Web
    destination_address_prefix = "*"
    destination_port_range     = "22"
    source_port_range          = "*"
  }
}

# קישור NSG לרמת ה־Subnet של DB
resource "azurerm_subnet_network_security_group_association" "db_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.db_subnet.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
  
  depends_on = [
    azurerm_network_security_group.db_nsg
  ]
}

# NIC for DB
resource "azurerm_network_interface" "db_nic" {
  name                = "simple-net-db-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "db-ipconfig"
    subnet_id                     = azurerm_subnet.db_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.2.5"
  }

  depends_on = [
  azurerm_virtual_network.vnet,
  azurerm_subnet.db_subnet
  ]
}

# DB VM
resource "azurerm_linux_virtual_machine" "db" {
  name                = var.db_vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.db_username

  network_interface_ids = [
    azurerm_network_interface.db_nic.id
  ]

  admin_ssh_key {
    username   = var.db_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = filebase64("cloud-init-db.yaml")

  depends_on = [
    azurerm_network_interface.db_nic
  ]
}