----monitoring----
 
##create  single metric alerts for cloud connector at one time

resource "azurerm_monitor_metric_alert" "alert" {

  for_each                 = { for m in var.vm_metric_alerts : m.alertName => m}

  name                     = each.value.alertName

  resource_group_name      = each.value.alertResourceGroupName

  scopes                   = each.value.scope_level == "Resource Group" ? ["/subscriptions/${var.subscriptionId}/resourceGroups/${each.value.alertResourceGroupName}"]:["/subscriptions/${var.subscriptionId}/resourceGroups/${each.value.alertResourceGroupName}/providers/Microsoft.Compute/virtualMachines/${each.value.alertScopes}"]

  description              = each.value.alertDescription

  enabled                  = tobool(lower(each.value.alertEnabled))

  auto_mitigate            = tobool(lower(each.value.alertAutoMitigate))

  frequency                = each.value.alertFrequency

  severity                 = each.value.severity

  window_size              = each.value.window_size

  target_resource_type     = each.value.alertTargetResourceType

  target_resource_location = try(each.value.alertTargetResourceLoc,null)
 
  criteria {

    metric_namespace = each.value.criteriaMetricNamespace

    metric_name      = each.value.criteriaMetricName

    aggregation      = each.value.criteriaAggregation

    operator         = each.value.criteriaOperator

    threshold        = each.value.criteriaThreshold
 
 
  }

  action {

   action_group_id = data.azurerm_monitor_action_group.vm-alert[each.value.alertName].id

  }

  tags                = merge(var.default_tags, 

                                     {

                                       wk_resource_name    = each.value.alertName

                                       wk_application_name ="monitoring"

                                       }

                                     )

        depends_on = [azurerm_linux_virtual_machine.cc_vm]

}
 