# create app service plan
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name

  kind     = "Linux"
  reserved = true

  sku {
    tier = var.app_service_plan_sku.tier
    size = var.app_service_plan_sku.size
  }
}

# create application insights
resource "azurerm_application_insights" "app_insights" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.application_insights_name
  application_type    = var.application_insights_type
}

# create azure app service
resource "azurerm_app_service" "app_service" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    dotnet_framework_version = "v4.0"
    always_on                = true
  }

  app_settings = merge(var.application_settings, {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights.instrumentation_key
  })
}
