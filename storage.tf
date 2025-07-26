resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "storage" {
  name                     = "simplenet${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "images" {
  name                  = "images"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

# ========== DB For Photo ==========
resource "azurerm_storage_account" "photo_storage" {
  name                     = "cloudphotoimages"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "photo_container" {
  name                  = "photos"
  storage_account_id    = azurerm_storage_account.photo_storage.id
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "sample_image" {
  name                   = "example.jpg"
  storage_account_name   = azurerm_storage_account.photo_storage.name
  storage_container_name = azurerm_storage_container.photo_container.name
  type                   = "Block"
  source                 = "example.jpg" # העלה את הקובץ הזה לתיקיית הקוד שלך
  content_type           = "image/jpeg"
}
