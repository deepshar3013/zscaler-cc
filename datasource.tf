----Data source----
 
data "azurerm_client_config" "current" {
}
data "azurerm_subscription" "current" {
}
 
data "azurerm_user_assigned_identity" "identity" {
  name                =  var.managed_identity_name
  resource_group_name =  var.managed_identity_resource_group
}
data "azurerm_subnet" "dmz" {
  for_each            =  { for v in var.zscaler_connectors :v.virtual_machine_name=>v}
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.vnet_resource_group_name
}
data "azurerm_monitor_action_group" "vm-alert" {
  for_each            = { for m in var.vm_metric_alerts: m.alertName => m}
  resource_group_name = each.value.ag_resource_group_name
  name                = each.value.ag_name
}