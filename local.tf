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
}
