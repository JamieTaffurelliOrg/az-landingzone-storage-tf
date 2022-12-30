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

variable "network_watcher_resource_group_name" {
  type        = string
  description = "The resource group of the network watcher"
}

variable "network_watchers" {
  type = map(object(
    {
      name     = string
      location = string
    }
  ))
  default     = {}
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

variable "log_analytics_workspace" {
  type = object(
    {
      name                = string
      resource_group_name = string
    }
  )
  description = "The existing log analytics workspaces to send diagnostic logs to"
}

variable "enable_aad_diagnostics" {
  type        = bool
  default     = false
  description = "Enable AAD activity logs diagnostics setting, this only needs to be done in one configuration per tenant"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resource group and storage account"
}
