module "aks_example_named_cluster" {
  source                               = "Azure/aks/azurerm"
  version                              = "6.2.0"
  prefix                               = "test"
  resource_group_name                  = var.resource_group_name
  admin_username                       = var.admin_username
  azure_policy_enabled                 = true
  #cluster_log_analytics_workspace_name = "test-aks-law"
  cluster_name                         = var.cluster_name
  location                             = var.location
  #log_retention_in_days                = var.log_retention_in_days
  depends_on = [time_sleep.wait_30_seconds]
}

resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "30s"
}

resource "null_resource" "account_association" {
    depends_on = [module.aks_example_named_cluster]
    provisioner "local-exec" {
        command = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.cluster_name}"
    }
}


module "ocean-aks-np" {
  
  #//source = "../.."
  source  = "spotinst/ocean-aks-np-k8s/spotinst"
  version = "0.6.2"
  # Credentials.
  spotinst_token                          = var.spotinst_token
  spotinst_account                        = var.spotinst_account

  # Configuration
  ocean_cluster_name                       = var.cluster_name
  aks_region                               = var.location
  controller_cluster_id                    = var.cluster_name
  aks_cluster_name                         = var.cluster_name
  aks_infrastructure_resource_group_name   = "MC_${var.resource_group_name}_${var.cluster_name}_${var.resource_group_location}"
  aks_resource_group_name                  = var.resource_group_name
  autoscaler_is_enabled                    = true
  autoscaler_resource_limits_max_vcpu      = 750
  autoscaler_resource_limits_max_memory_gib= 1500
  autoscaler_max_scale_down_percentage     = 30
  autoscaler_headroom_automatic_percentage = 5
  health_grace_period                      = 600
  max_pods_per_node                        = 30
  enable_node_public_ip                    = true
  os_disk_size_gb                          = 32
  os_disk_type                             = "Managed"
  os_type                                  = "Linux"
  node_min_count                           = 1
  node_max_count                           = 100
  spot_percentage                          = 50
  fallback_to_ondemand                     = true
  autoscale_headrooms_cpu_per_unit         = 6
  autoscale_headrooms_memory_per_unit      = 10
  autoscale_headrooms_gpu_per_unit         = 4
  autoscale_headrooms_num_of_units         = 10
  availability_zones                       = ["1", "2", "3"]
  tags                                     = { "tagKey": "env", "tagValue": "staging" }
  labels                                   = { "key": "env","value": "test"}
  taints                                   = [{"key":"taintKey","value":"taintValue", "effect" : "NoSchedule"}]
  vmsizes_filters_min_vcpu                 = 2
  vmsizes_filters_max_vcpu                 = 16
  vmsizes_filters_min_memory_gib           = 10
  vmsizes_filters_max_memory_gib           = 18
  //vmsizes_filters_series                   = ["D v3", "Dds_v4", "Dsv2"]
  vmsizes_filters_architectures            = ["X86_64"]
  shutdown_hours                           = { is_enabled = false,
                                               time_windows = ["Fri:15:30-Sat:13:30", "Sun:15:30-Mon:13:30"] }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "ocean-controller" {
  source = "spotinst/ocean-controller/spotinst"
  depends_on = [ null_resource.account_association ]
  # Credentials.
  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account

  # Configuration.
  cluster_identifier = var.cluster_name
}

module "ocean-aks-np-vng" {
  depends_on = [module.ocean-aks-np]
  source = "spotinst/ocean-aks-np-k8s-vng/spotinst"
  ocean_vng_name                            = "testVng"
  ocean_id                                  = module.ocean-aks-np.ocean_id
  autoscale_headrooms_cpu_per_unit          = 1024
  autoscale_headrooms_memory_per_unit       = 512
  autoscale_headrooms_gpu_per_unit          = 0
  autoscale_headrooms_num_of_units          = 2
  availability_zones                        = ["1", "2", "3"]
  max_pods_per_node                         = 30
  enable_node_public_ip                     = true
  os_disk_size_gb                           = 32
  os_disk_type                              = "Managed"
  os_type                                   = "Linux"
  node_min_count                            = 1
  node_max_count                            = 100
  spot_percentage                           = 50
  fallback_to_ondemand                      = true
  tags                                      = { "tagKey": "env", "tagValue": "staging" }
  labels                                    = { "key": "env","value": "test"}
  taints                                    = [{"key":"taintKey","value":"taintValue", "effect" : "NoSchedule"}]
  vmsizes_filters_min_vcpu                  = 2
  vmsizes_filters_max_vcpu                  = 16
  vmsizes_filters_min_memory_gib            = 10
  vmsizes_filters_max_memory_gib            = 18
  vmsizes_filters_series                    = ["D v3", "Dds_v4", "Dsv2"]
  vmsizes_filters_architectures             = ["X86_64"]
}