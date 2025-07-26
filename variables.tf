# ========== General ==========
variable "location" {
  description = "Azure region for all resources"
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the existing Resource Group"
  type        = string
  default     = "rg-rotem"
}

variable "ssh_public_key" {
  description = "Public SSH key used for VM access"
  type        = string
}

# ========== Network ==========
variable "vnet_name" {
  description = "Name of the Virtual Network"
  default     = "simple-net-vnet"
}

variable "address_space" {
  description = "Address space for the Virtual Network"
  default     = ["10.1.0.0/16"]
}

# Web Subnet
variable "web_subnet_name" {
  description = "Name of the subnet for the Web VM"
  default     = "subnet-web"
}

variable "web_subnet_prefix" {
  description = "Address prefix for the Web subnet"
  default     = ["10.1.1.0/24"]
}

# DB Subnet
variable "db_subnet_name" {
  description = "Name of the subnet for the DB VM"
  default     = "subnet-db"
}

variable "db_subnet_prefix" {
  description = "Address prefix for the DB subnet"
  default     = ["10.1.2.0/24"]
}

# ========== Virtual Machines ==========
variable "web_vm_name" {
  description = "Name of the Web VM"
  default     = "simple-net-web"
}

variable "db_vm_name" {
  description = "Name of the DB VM"
  default     = "simple-net-db"
}

variable "admin_username" {
  description = "Admin username for the Web VM"
  default     = "devuser"
}

variable "db_username" {
  description = "Admin username for the DB VM"
  default     = "dbuser"
}