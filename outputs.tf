output "storage_account" {
  value       = azurerm_storage_account.storage
  sensitive   = true
  description = "Properties of the Storage Accounts"
}
