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
