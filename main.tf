resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "network_watcher_resource_group" {
  name     = var.network_watcher_resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_watcher" "logging" {
  for_each            = var.network_watchers
  name                = each.value.name
  resource_group_name = azurerm_resource_group.network_watcher_resource_group.name
  location            = each.value.location
  tags                = var.tags
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

resource "azurerm_monitor_diagnostic_setting" "storage_account_diagnostics" {
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

  metric {
    category = "Capacity"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_blob_diagnostics" {
  for_each                   = toset(["blobServices", "fileServices", "tableServices", "queueServices"])
  name                       = "${var.log_analytics_workspace.name}-security-logging"
  target_resource_id         = "${azurerm_storage_account.storage.id}/${each.key}/default/"
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

  metric {
    category = "Capacity"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_management_lock" "delete_lock" {
  name       = "resource-group-level"
  scope      = azurerm_resource_group.resource_group.id
  lock_level = "CanNotDelete"
  notes      = "Managed by Terraform"
}

resource "azurerm_management_lock" "network_watcher_delete_lock" {
  name       = "resource-group-level"
  scope      = azurerm_resource_group.network_watcher_resource_group.id
  lock_level = "CanNotDelete"
  notes      = "Managed by Terraform"
}

resource "azurerm_security_center_subscription_pricing" "security_plans_no_sub_plan" {
  for_each      = toset(local.defender_for_cloud_plans)
  tier          = "Standard"
  resource_type = each.key
}

resource "azurerm_security_center_subscription_pricing" "security_plans_sub_plan" {
  for_each      = { for mdc_plans in local.defender_for_cloud_sub_plans : mdc_plans.plan => mdc_plans }
  tier          = "Standard"
  resource_type = each.value["plan"]
  subplan       = each.value["sub_plan"]
}

resource "azurerm_security_center_workspace" "example" {
  scope        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  workspace_id = data.azurerm_log_analytics_workspace.logs.id
}

resource "azurerm_monitor_aad_diagnostic_setting" "aad_diagnostics" {
  count                      = var.enable_aad_diagnostics == true ? 1 : 0
  name                       = "${var.log_analytics_workspace.name}-security-logging"
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  log {
    category = "SignInLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "AuditLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "NonInteractiveUserSignInLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "ServicePrincipalSignInLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "ManagedIdentitySignInLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "ProvisioningLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
  log {
    category = "ADFSSignInLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "RiskyUsers"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "UserRiskEvents"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "NetworkAccessTrafficLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "RiskyServicePrincipals"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "ServicePrincipalRiskEvents"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "activity_logs" {
  name                       = "${var.log_analytics_workspace.name}-security-logging"
  target_resource_id         = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  log {
    category = "Administrative"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "Security"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "ServiceHealth"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "Alert"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "Recommendation"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "Policy"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "Autoscale"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "ResourceHealth"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}
