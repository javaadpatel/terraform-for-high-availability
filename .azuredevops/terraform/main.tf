/*
    Initializing Terraform you need to run:
    terraform init -backend-config=<path to backend config file> 
    eg:
    terraform init -backend-config="./variables/backends/dev.backend.tfvars"

    See the execution plan using:
    terraform plan -var-file=<path to variable configuration file>
    eg:
    terraform plan -var-file="./variables/dev.tfvars"

    Apply the execution plan using:
    terraform apply -var-file=<path to variable configuration file>
    eg:
    terraform apply -var-file="./variables/dev.tfvars"

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

# Configure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.primary_location
}

# Configure CosmosDB
module "cosmosdb" {
  source = "./modules/azure-cosmosdb"

  resource_group_name = var.resource_group_name
  primary_location    = var.primary_location
  secondary_location  = var.secondary_location
account_name = var.cosmosdb_account_name
}


# Configure Azure App Service
module "app_service" {
  source = "./modules/azure-app-service"

  resource_group_name = var.resource_group_name
  location            = var.primary_location

  app_service_plan_name     = var.app_service_plan_name
  app_service_plan_sku      = var.app_service_plan_sku
  application_insights_name = var.app_service_application_insights_name
  app_service_name          = var.app_service_name
}
