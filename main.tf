resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "storage" {
  name                            = var.storage_account_name
  location                        = var.location
  resource_group_name             = azurerm_resource_group.resource_group.name
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  access_tier                     = "Hot"
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  default_to_oauth_authentication = true

  blob_properties {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 365
    last_access_time_enabled      = true

    delete_retention_policy {
      days = 365
    }

    container_delete_retention_policy {
      days = 365
    }
  }

  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

resource "azurerm_storage_container" "container" {
  for_each              = toset(var.containers)
  name                  = each.key
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_account_network_rules" "rules" {
  storage_account_id         = azurerm_storage_account.storage.id
  default_action             = var.storage_account_network_rules.default_action
  ip_rules                   = var.storage_account_network_rules.ip_rules
  virtual_network_subnet_ids = var.storage_account_network_rules.virtual_network_subnet_ids
  bypass                     = ["Logging", "Metrics", "AzureServices"]
}

/*resource "azurerm_monitor_diagnostic_setting" "storage_account_diagnostics" {
  name                       = "${var.log_analytics_workspace.name}-security-logging"
  target_resource_id         = azurerm_storage_account.storage.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  metric {
    category = "Transaction"

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_blob_diagnostics" {
  for_each                   = toset(["blobServices", "fileServices", "tableServices", "queueServices"])
  name                       = "${var.log_analytics_workspace.name}-security-logging"
  target_resource_id         = "${azurerm_storage_account.storage.id}/blobServices/default/"
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  log {
    category = "StorageRead"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "StorageWrite"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "StorageDelete"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "Transaction"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}*/

resource "azurerm_management_lock" "delete_lock" {
  name       = "resource-group-level"
  scope      = azurerm_resource_group.resource_group.id
  lock_level = "CanNotDelete"
  notes      = "Managed by Terraform"
}
