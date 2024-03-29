# az-landingzone-storage-tf

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.49.0 |
| <a name="provider_azurerm.logs"></a> [azurerm.logs](#provider\_azurerm.logs) | 3.49.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cost_anomaly_alert.cost_anomaly](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cost_anomaly_alert) | resource |
| [azurerm_management_lock.delete_lock](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_management_lock.network_watcher_delete_lock](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_diagnostic_setting.activity_logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_account_blob_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_account_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_watcher.logging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher) | resource |
| [azurerm_resource_group.network_watcher_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_provider_registration.provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_provider_registration) | resource |
| [azurerm_security_center_subscription_pricing.security_plans_no_sub_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing) | resource |
| [azurerm_security_center_subscription_pricing.security_plans_sub_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing) | resource |
| [azurerm_security_center_workspace.workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_workspace) | resource |
| [azurerm_storage_account.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_subscription_template_deployment.budget_template](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_template_deployment) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_log_analytics_workspace.logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_budgets"></a> [budgets](#input\_budgets) | Budgets to apply | <pre>list(object({<br>    name     = string<br>    amount   = number<br>    category = string<br>    filter   = optional(map(string), {})<br>    notifications = map(object({<br>      enabled       = optional(bool, true)<br>      operator      = string<br>      threshold     = number<br>      contactEmails = optional(list(string))<br>      thresholdType = optional(string, "Actual")<br>    }))<br>    time_grain = optional(string, "Monthy")<br>    end_date   = optional(string, "")<br>    start_date = optional(string, "")<br>  }))</pre> | `[]` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | The storage account containers to store state files for each subscription | `list(string)` | n/a | yes |
| <a name="input_cost_email_addresses"></a> [cost\_email\_addresses](#input\_cost\_email\_addresses) | Email addresses to send cost alerts to | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location of the storage account to store state files | `string` | n/a | yes |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | The existing log analytics workspaces to send diagnostic logs to | <pre>object(<br>    {<br>      name                = optional(string)<br>      resource_group_name = optional(string)<br>    }<br>  )</pre> | `{}` | no |
| <a name="input_network_watchers"></a> [network\_watchers](#input\_network\_watchers) | Name and location of the Network Watchers to deploy | <pre>object(<br>    {<br>      resource_group_name = string<br>      network_watchers = map(object({<br>        name     = string<br>        location = string<br>      }))<br>      tags = map(string)<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_registered_providers"></a> [registered\_providers](#input\_registered\_providers) | Enable Resource Providers on the subscription | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group of the storage account to store state files | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the storage account to store state files | `string` | n/a | yes |
| <a name="input_storage_account_network_rules"></a> [storage\_account\_network\_rules](#input\_storage\_account\_network\_rules) | The Storage Account firewall rules | <pre>object(<br>    {<br>      default_action             = optional(string, "Deny")<br>      ip_rules                   = optional(list(string), [])<br>      virtual_network_subnet_ids = optional(list(string), [])<br>    }<br>  )</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resource group and storage account | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account) | Properties of the Storage Accounts |
<!-- END_TF_DOCS -->
