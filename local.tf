locals {
  defender_for_cloud_plans = [
    "AppServices", "ContainerRegistry", "KeyVaults", "KubernetesService", "SqlServers", "SqlServerVirtualMachines", "Arm", "OpenSourceRelationalDatabases", "Containers", "Dns"
  ]
  defender_for_cloud_sub_plans = [
    {
      plan     = "StorageAccounts"
      sub_plan = "PerTransaction"
    },
    {
      plan     = "VirtualMachines"
      sub_plan = "P2"
    }
  ]

  boot_diagnostic_settings = distinct(flatten([
    for bsa in var.boot_diagnostic_storage_accounts : [
      for diag in ["blobServices", "fileServices", "tableServices", "queueServices"] : {
        storage_account_name = bsa.name
        service              = diag
      }
  ]]))
}
