resource "azurerm_traffic_manager_endpoint" "endpoint" {
  name                = var.name
  resource_group_name = var.resource_group_name
  profile_name        = var.profile_name
  type                = "azureEndpoints"
  target_resource_id  = var.endpoint_id
  priority            = var.priority
}
