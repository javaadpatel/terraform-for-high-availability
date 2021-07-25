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
  #Calculate variable names in combination with the region for region specific resources
  location           = var.is_primary_deployment == true ? var.primary_location : var.secondary_location
  formatted_location = replace(lower(local.location), " ", "")

  app_service_plan_name                 = "${var.app_service_plan_name}-${local.formatted_location}"
  app_service_application_insights_name = "${var.app_service_application_insights_name}-${local.formatted_location}"
  app_service_name                      = "${var.app_service_name}-${local.formatted_location}"

  app_service_name_primary   = "${var.app_service_name}-${replace(lower(var.primary_location), " ", "")}"
  app_service_name_secondary = "${var.app_service_name}-${replace(lower(var.secondary_location), " ", "")}"

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
module "app_service" {
  source = "./modules/azure-app-service"

  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location

  app_service_plan_name     = local.app_service_plan_name
  app_service_plan_sku      = var.app_service_plan_sku
  application_insights_name = local.app_service_application_insights_name
  app_service_name          = local.app_service_name
  application_settings = {
    "cosmosdb_endpoint" : module.cosmosdb.endpoint
  }
}

# Configure Azure Traffic Manager
module "traffic_manager" {
  source = "./modules/azure-traffic-manager"
  depends_on = [
    module.app_service,
  ]

  resource_group_name   = azurerm_resource_group.rg.name
  profile_name          = var.traffic_manager_profile_name
  primary_endpoint_id   = local.primary_endpoint_id
  secondary_endpoint_id = var.is_primary_deployment ? "null" : local.secondary_endpoint_id
}
