resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "network_watcher_resource_group" {
  name     = var.network_watchers.resource_group_name
  location = var.location
  tags     = var.network_watchers.tags
}

resource "azurerm_network_watcher" "logging" {
  for_each            = var.network_watchers.network_watchers
  name                = each.value.name
  resource_group_name = azurerm_resource_group.network_watcher_resource_group.name
  location            = each.value.location
  tags                = var.network_watchers.tags
}

resource "azurerm_storage_account" "storage" {
  #checkov:skip=CKV2_AZURE_33:This is an old way of logging, diagnostics are enabled
  #checkov:skip=CKV_AZURE_33:This is an old way of logging, diagnostics are enabled
  #checkov:skip=CKV2_AZURE_18:This is unnecessary for most scenarios
  #checkov:skip=CKV2_AZURE_1:We may require some storage accounts to not have firewalls
  #checkov:skip=CKV_AZURE_59:Value is deprecated
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
  shared_access_key_enabled       = false
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
  #checkov:skip=CKV2_AZURE_21:This is an old way of logging, diagnostics are enabled
  for_each              = toset(var.containers)
  name                  = each.key
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_account_network_rules" "rules" {
  #checkov:skip=CKV_AZURE_35:We may require these storage accounts to be publicly accessible
  storage_account_id         = azurerm_storage_account.storage.id
  default_action             = var.storage_account_network_rules.default_action
  ip_rules                   = var.storage_account_network_rules.ip_rules
  virtual_network_subnet_ids = var.storage_account_network_rules.virtual_network_subnet_ids
  bypass                     = ["Logging", "Metrics", "AzureServices"]
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_diagnostics" {
  count                      = var.log_analytics_workspace.name != null ? 1 : 0
  name                       = "${var.log_analytics_workspace.name}-security-logging"
  target_resource_id         = azurerm_storage_account.storage.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs[0].id

  metric {
    category = "Transaction"
  }

  metric {
    category = "Capacity"
    enabled  = false
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_blob_diagnostics" {
  for_each                   = var.log_analytics_workspace.name != null ? toset(["blobServices", "fileServices", "tableServices", "queueServices"]) : toset([])
  name                       = "${var.log_analytics_workspace.name}-security-logging"
  target_resource_id         = "${azurerm_storage_account.storage.id}/${each.key}/default/"
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs[0].id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }

  metric {
    category = "Capacity"
    enabled  = false
  }
}

resource "azurerm_management_lock" "delete_lock" {
  name       = "resource-group-level"
  scope      = azurerm_resource_group.resource_group.id
  lock_level = "CanNotDelete"
  notes      = "Managed by Terraform"
  depends_on = [
    azurerm_monitor_diagnostic_setting.storage_account_blob_diagnostics,
    azurerm_monitor_diagnostic_setting.storage_account_diagnostics,
    azurerm_storage_account_network_rules.rules,
    azurerm_storage_container.container,
    azurerm_network_watcher.logging
  ]
}

resource "azurerm_management_lock" "network_watcher_delete_lock" {
  name       = "resource-group-level"
  scope      = azurerm_resource_group.network_watcher_resource_group.id
  lock_level = "CanNotDelete"
  notes      = "Managed by Terraform"
}

resource "azurerm_security_center_subscription_pricing" "security_plans_no_sub_plan" {
  #checkov:skip=CKV_AZURE_234:ARM is enabled, plus many more
  for_each      = toset(local.defender_for_cloud_plans)
  tier          = "Standard"
  resource_type = each.key
}

resource "azurerm_security_center_subscription_pricing" "security_plans_sub_plan" {
  #checkov:skip=CKV_AZURE_234:ARM is enabled, plus many more
  for_each      = { for mdc_plans in local.defender_for_cloud_sub_plans : mdc_plans.plan => mdc_plans }
  tier          = "Standard"
  resource_type = each.value["plan"]
  subplan       = each.value["sub_plan"]
}

resource "azurerm_security_center_workspace" "workspace" {
  count        = var.log_analytics_workspace.name != null ? 1 : 0
  scope        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  workspace_id = data.azurerm_log_analytics_workspace.logs[0].id
}

resource "azurerm_resource_provider_registration" "provider" {
  for_each = toset(var.registered_providers)
  name     = each.key
}

resource "azurerm_cost_anomaly_alert" "cost_anomaly" {
  name            = "${data.azurerm_subscription.current.display_name}-daily-anomaly-by-resource-group"
  display_name    = "${data.azurerm_subscription.current.display_name} Daily Anomaly by Resource Group"
  email_subject   = "${data.azurerm_subscription.current.display_name} Daily Anomaly by Resource Group"
  email_addresses = var.cost_email_addresses
}

resource "azurerm_subscription_template_deployment" "budget_template" {
  for_each         = { for budget in local.budgets : budget.name => budget }
  name             = "${data.azurerm_subscription.current.display_name}-${each.key}"
  template_content = file("arm/budgetTemplate.json")
  location         = var.location
  parameters_content = jsonencode({
    "budgetName" = {
      value = "${data.azurerm_subscription.current.display_name}-${each.key}"
    },
    "amount" = {
      value = each.value["amount"]
    },
    "category" = {
      value = each.value["category"]
    },
    "filter" = {
      value = keys(each.value["filter"])[0] == "" ? {} : each.value["filter"]
    },
    "notifications" = {
      value = each.value["notifications"]
    },
    "timeGrain" = {
      value = each.value["time_grain"]
    },
    "endDate" = {
      value = each.value["end_date"]
    },
    "startDate" = {
      value = each.value["start_date"] == "" ? "${formatdate("YYYY-MM", timestamp())}-01" : each.value["start_date"]
    }
  })
}

resource "azurerm_monitor_diagnostic_setting" "activity_logs" {
  count                      = var.log_analytics_workspace.name != null ? 1 : 0
  name                       = "${var.log_analytics_workspace.name}-security-logging"
  target_resource_id         = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs[0].id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "ServiceHealth"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Recommendation"
  }

  enabled_log {
    category = "Policy"
  }

  enabled_log {
    category = "Autoscale"
  }

  enabled_log {
    category = "ResourceHealth"
  }
}
