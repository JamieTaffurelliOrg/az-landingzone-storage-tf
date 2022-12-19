terraform {
  required_providers {
    azurerm = {
      configuration_aliases = [azurerm.logs]
      source                = "hashicorp/azurerm"
      version               = "~> 3.20"
    }
  }
  required_version = "~> 1.3.0"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azurerm" {
  alias = "logs"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
