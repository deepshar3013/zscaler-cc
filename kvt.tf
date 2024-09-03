---kvt---
 
resource "azurerm_role_assignment" "role" {
  scope                = data.azurerm_subscription.current.id
  role_definition_id   ="/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7"
  principal_id         = data.azurerm_user_assigned_identity.identity.principal_id
}
 
resource "azurerm_key_vault_access_policy" "policy" {
  key_vault_id = "/subscriptions/${var.subscriptionId}/resourceGroups/${var.keyvault_resource_group}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}"
  tenant_id    = data.azurerm_user_assigned_identity.identity.tenant_id
  object_id    = data.azurerm_user_assigned_identity.identity.principal_id
 
  key_permissions = [
     "Get","List",
  ]
 
  secret_permissions = [
    "Get","List",
  ]
  certificate_permissions = []
  storage_permissions     = []
    lifecycle {
    ignore_changes = [
      tenant_id,object_id,  // Ignore changes to app_settings attribute
    ]
  }
}
 
###################################################################################
# Key Vault secret
##################################################################################
resource "random_password" "vmccpassword" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:"
}
#Create Key Vault Secret
resource "azurerm_key_vault_secret" "vmccpassword" {
  for_each     = { for v in var.zscaler_connectors :v.virtual_machine_name=>v}
  name         = each.value.vm_secret_name
  value        = random_password.vmccpassword.result
  key_vault_id = "/subscriptions/${var.subscriptionId}/resourceGroups/${var.keyvault_resource_group}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}"
}