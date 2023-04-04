terraform {
  required_providers {
    azurerm = {
      configuration_aliases = [azurerm.logs]
      source                = "hashicorp/azurerm"
      version               = "~> 3.20"
    }
  }
  required_version = "~> 1.4.0"
}
