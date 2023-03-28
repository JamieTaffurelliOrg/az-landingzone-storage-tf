data "azurerm_client_config" "current" {
}

data "azurerm_log_analytics_workspace" "logs" {
  count               = var.log_analytics_workspace.name != null ? 1 : 0
  provider            = azurerm.logs
  name                = var.log_analytics_workspace.name
  resource_group_name = var.log_analytics_workspace.resource_group_name
}
