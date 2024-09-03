----variable----
 
####################################tags#######################################################
variable "default_tags" {
  description = "Option to enabled or disable default tags"
  type        = map(string)
  default     = {}
}
variable "extra_tags" {
  description = "Tags "
  type        = map(string)
  default     = {}
}
######################################ZCC######################################################
variable "zscaler_connectors" {
  description = "Zscaler cloud connector details "
  type = any
}
variable "vm_metric_alerts" {
  description = "Zscaler cloud connector vm metric alert details "
  type = any
}
// variable "lb_metric_alerts" {
//   description = "Zscaler cloud connector load balancer metric alert details "
//   type = any
// }
// variable "lb_resourceHealth" {
//   description = "Zscaler cloud connector load balancer metric alert details "
//   type = any
// }
###################################Managed Identities ########################################
variable "managed_identity_name"{
  description = "Managed Identities name"
  type        = string
}
variable "managed_identity_resource_group"{
  description = "Managed Identities resource group"
  type        = string
}
variable "subscriptionId"{
  description = "subscription id"
  type        = string
}
##############################Key-Vault#################################
variable "key_vault_name" {
  type        = string
  description  = "Name of the key azurerm_key_vault"
}
variable "keyvault_resource_group" {
  type        = string
  description  = "rg of the key azurerm_key_vault"
}
variable "location" {
  type        = string
  description  = "location of the key azurerm_key_vault"
}
 
variable "custom_data" {
  description = "custom data to execute bootstrap commands for Virtual machine "
  type = string
}