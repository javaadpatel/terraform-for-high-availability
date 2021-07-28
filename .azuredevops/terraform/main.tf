/*
    Initializing Terraform you need to run:
    terraform init -backend-config=<path to backend config file> 
    eg:
    terraform init -backend-config="./variables/backends/dev.backend.tfvars"

    See the execution plan using:
    terraform plan -var-file=<path to variable configuration file>
    eg:
    terraform plan -var-file="./variables/dev.tfvars" -var-file="./variables/dev.primary.tfvars"

    Apply the execution plan using:
    terraform apply -var-file=<path to variable configuration file>
    eg:
    terraform apply -var-file="./variables/dev.tfvars" -var-file="./variables/dev.primary.tfvars"

    Destroy created infrastructure using:
    terraform destroy -var-file=<path to variable configuration file>
    eg:
    terraform destroy -var-file="./variables/dev.tfvars"
*/

# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.26"
    }
  }

  backend "azurerm" {
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

data "azurerm_subscription" "current" {
}

locals {
  primary_location_formatted   = replace(lower(var.primary_location), " ", "")
  secondary_location_formatted = replace(lower(var.secondary_location), " ", "")

  app_service_name_primary   = "${var.app_service_name}-${local.primary_location_formatted}"
  app_service_name_secondary = "${var.app_service_name}-${local.secondary_location_formatted}"

  app_service_plan_name_primary   = "${var.app_service_plan_name}-${local.primary_location_formatted}"
  app_service_plan_name_secondary = "${var.app_service_plan_name}-${local.secondary_location_formatted}"

  app_service_application_insights_name_primary   = "${var.app_service_application_insights_name}-${local.primary_location_formatted}"
  app_service_application_insights_name_secondary = "${var.app_service_application_insights_name}-${local.secondary_location_formatted}"

  subscription_id       = data.azurerm_subscription.current.subscription_id
  primary_endpoint_id   = "/subscriptions/${local.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Web/sites/${local.app_service_name_primary}"
  secondary_endpoint_id = "/subscriptions/${local.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Web/sites/${local.app_service_name_secondary}"
}

# Configure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.primary_location
}

# Configure CosmosDB
module "cosmosdb" {
  source = "./modules/azure-cosmosdb"

  resource_group_name = azurerm_resource_group.rg.name
  primary_location    = var.primary_location
  secondary_location  = var.secondary_location
  account_name        = var.cosmosdb_account_name
}

# Configure Azure App Service
# Primary region app service
module "app_service_primary" {
  source = "./modules/azure-app-service"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.primary_location

  app_service_plan_name     = local.app_service_plan_name_primary
  app_service_plan_sku      = var.app_service_plan_sku
  application_insights_name = local.app_service_application_insights_name_primary
  app_service_name          = local.app_service_name_primary
  application_settings = {
    "cosmosdb_endpoint" : module.cosmosdb.endpoint
  }
}

# Secondary region app service (only deployed if its a secondary deployment)
module "app_service_secondary" {
  source = "./modules/azure-app-service"
  count  = var.is_primary_deployment ? 0 : 1

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.secondary_location

  app_service_plan_name     = local.app_service_plan_name_secondary
  app_service_plan_sku      = var.app_service_plan_sku
  application_insights_name = local.app_service_application_insights_name_secondary
  app_service_name          = local.app_service_name_secondary
  application_settings = {
    "cosmosdb_endpoint" : module.cosmosdb.endpoint
  }
}

# Configure Azure Traffic Manager Profile
module "traffic_manager_profile" {
  source = "./modules/azure-traffic-manager"
  depends_on = [
    module.app_service_primary
  ]

  resource_group_name = azurerm_resource_group.rg.name
  profile_name        = var.traffic_manager_profile_name
}

module "primary_endpoint" {
  source = "./modules/azure-traffic-manager-endpoint"
  depends_on = [
    module.traffic_manager_profile
  ]

  resource_group_name = azurerm_resource_group.rg.name
  name                = "primary_endpoint"
  profile_name        = var.traffic_manager_profile_name
  endpoint_id         = local.primary_endpoint_id
  priority            = 1
}

module "secondary_endpoint" {
  source = "./modules/azure-traffic-manager-endpoint"
  count  = var.is_primary_deployment ? 0 : 1
  depends_on = [
    module.app_service_secondary,
  ]

  resource_group_name = azurerm_resource_group.rg.name
  name                = "secondary_endpoint"
  profile_name        = var.traffic_manager_profile_name
  endpoint_id         = local.secondary_endpoint_id
  priority            = 2
}
