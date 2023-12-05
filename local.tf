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
}
