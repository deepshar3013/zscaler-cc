----vm----
 
################################################################################
# Create Cloud Connector VM
################################################################################
resource "azurerm_linux_virtual_machine" "cc_vm" {
  for_each                   = { for v in var.zscaler_connectors :v.virtual_machine_name=>v}
  name                       = each.value.virtual_machine_name
  location                   = var.location
  resource_group_name        = each.value.resource_group
  size                       = each.value.ccvm_instance_type
  zone                       = each.value.zone
  encryption_at_host_enabled = each.value.encryption_at_host_enabled
  disable_password_authentication = false
  provision_vm_agent              = true
 
  # Cloud Connector requires that the ordering of network_interface_ids associated are #1/mgmt, #2/service (or lb for med/lrg CC), #3/service-1, #4/service-2, #5/service-3 
  network_interface_ids = [
    azurerm_network_interface.cc_mgmt_nic[each.value.virtual_machine_name].id,
    azurerm_network_interface.cc_service_primary[each.value.virtual_machine_name].id
  ]
 
  computer_name  = lower(each.value.virtual_machine_name)
  custom_data    =  base64encode(var.custom_data)
  admin_username = each.value.admin_username
  admin_password = azurerm_key_vault_secret.vmccpassword[each.key].value
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
 
   source_image_reference {
      publisher = each.value.ccvm_image_publisher #zscaler1579058425289
      offer     = each.value.ccvm_image_offer #zia_cloud_connector
      sku       = each.value.ccvm_image_sku #zs_ser_gen1_cc_01
      version   = each.value.ccvm_image_version #latest
  }
 
   plan {
 
      publisher = each.value.ccvm_image_publisher  #zscaler1579058425289
      name      = each.value.ccvm_image_sku #zs_ser_gen1_cc_01
      product   = each.value.ccvm_image_offer #zia_cloud_connector
  }
 
    identity {
      type         = "UserAssigned"
      identity_ids = [data.azurerm_user_assigned_identity.identity.id]
    }
 
  tags                = merge(var.default_tags, var.extra_tags,
                                     {
                                       wk_resource_name    = each.value.virtual_machine_name
                                       }
                                     )
 
  lifecycle {
    ignore_changes = [network_interface_ids] #ignore the fallback network interface association for small/medium CCs so terraform doesn't think it needs to update them on subsequent applies
  }
 
}
 
 
data "azurerm_managed_disk" "disk" {
  for_each                = { for v in var.zscaler_connectors :v.virtual_machine_name=>v}
  name                    = azurerm_linux_virtual_machine.cc_vm[each.key].os_disk[0].name
  resource_group_name     = each.value.resource_group
}
 
resource "azapi_resource_action" "tags" {
  for_each      = data.azurerm_managed_disk.disk
  type          = "Microsoft.Compute/disks@2022-03-02"
  resource_id   = each.value.id
  method        = "PATCH"
 
  body = jsonencode({
    tags        = {
                    wk_resource_name    = lower(each.value.name)
                  }
  })
}