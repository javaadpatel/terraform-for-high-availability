# Configure traffic manager profile
resource "random_id" "server" {
  keepers = {
    azi_id = 1
  }

  byte_length = 8
}

resource "azurerm_traffic_manager_profile" "profile" {
  name                   = var.profile_name
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = random_id.server.hex
    ttl           = 100
  }

  monitor_config {
    #protocol                     = "http"
    # port                         = 80
    protocol                     = "https"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

}

# Configure endpoints
resource "azurerm_traffic_manager_endpoint" "primary_endpoint" {
  name                = "primary_endpoint"
  resource_group_name = var.resource_group_name
  profile_name        = azurerm_traffic_manager_profile.profile.name
  type                = "azureEndpoints"
  target_resource_id  = var.primary_endpoint_id
  priority            = 1
}

resource "azurerm_traffic_manager_endpoint" "secondary_endpoint" {
  # we can't create this endpoint until a secondary endpoint actually exists
  count               = var.secondary_endpoint_id == "null" ? 0 : 1
  name                = "secondary_endpoint"
  resource_group_name = var.resource_group_name
  profile_name        = azurerm_traffic_manager_profile.profile.name
  type                = "azureEndpoints"
  target_resource_id  = var.secondary_endpoint_id
  priority            = 2
}
