locals {
  defender_for_cloud_plans = [
    "AppServices", "ContainerRegistry", "KubernetesService", "SqlServers", "SqlServerVirtualMachines", "OpenSourceRelationalDatabases", "Containers", "Dns"
  ]
  defender_for_cloud_sub_plans = [
    {
      plan     = "StorageAccounts"
      sub_plan = "PerTransaction"
    },
    {
      plan     = "VirtualMachines"
      sub_plan = "P2"
    },
    {
      plan     = "Arm"
      sub_plan = "PerApiCall"
    },
    {
      plan     = "KeyVaults"
      sub_plan = "PerTransaction"
    }
  ]
  budgets = length(var.budgets) == 0 ? tolist([
    {
      budgetName = "cost-budget"
      amount     = 1000
      category   = "Cost"
      notifications = tomap({
        "BudgetExceeded" = {
          enabled       = true
          operator      = "GreaterThan"
          threshold     = 90
          contactEmails = var.cost_email_addresses
        }
        "BudgetForecastExceeded" = {
          enabled       = true
          operator      = "GreaterThan"
          threshold     = 110
          contactEmails = var.cost_email_addresses
          thresholdType = "Forecasted"
        }
      })
      timeGrain = "Monthly"
    }
  ]) : var.budgets
}
