variable "storage_account_name" {
  type        = string
  description = "The name of the storage account to store state files"
}

variable "location" {
  type        = string
  description = "The location of the storage account to store state files"
}

variable "resource_group_name" {
  type        = string
  description = "The resource group of the storage account to store state files"
}

variable "network_watchers" {
  type = object(
    {
      resource_group_name = string
      network_watchers = map(object({
        name     = string
        location = string
      }))
      tags = map(string)
    }
  )
  description = "Name and location of the Network Watchers to deploy"
}

variable "containers" {
  type        = list(string)
  description = "The storage account containers to store state files for each subscription"
}

variable "storage_account_network_rules" {
  type = object(
    {
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }
  )
  default     = {}
  description = "The Storage Account firewall rules"
}

variable "registered_providers" {
  type        = list(string)
  default     = []
  description = "Enable Resource Providers on the subscription"
}

variable "cost_email_addresses" {
  type        = list(string)
  description = "Email addresses to send cost alerts to"
}

variable "budgets" {
  type = list(object({
    name     = string
    amount   = number
    category = string
    filter   = optional(map(string), {})
    notifications = map(object({
      enabled       = optional(bool, true)
      operator      = string
      threshold     = number
      contactEmails = optional(list(string))
      thresholdType = optional(string, "Actual")
    }))
    time_grain = optional(string, "Monthy")
    end_date   = optional(string, "")
    start_date = optional(string, "")
  }))
  default     = []
  description = "Budgets to apply"
}

variable "log_analytics_workspace" {
  type = object(
    {
      name                = optional(string)
      resource_group_name = optional(string)
    }
  )
  default     = {}
  description = "The existing log analytics workspaces to send diagnostic logs to"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resource group and storage account"
}
