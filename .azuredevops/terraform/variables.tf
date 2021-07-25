# General
variable "resource_group_name" {
  type        = string
  description = "The resource group that the resources will be deployed into"
}

variable "is_primary_deployment" {
  type        = bool
  description = "Indicates if this is the primary or secondary deployment"
}

variable "primary_location" {
  type        = string
  description = "The primary region that the resources will be deployed into"
}

variable "secondary_location" {
  type        = string
  description = "The primary region that the resources will be deployed into"
}

# App Service Plan
variable "app_service_plan_name" {
  type        = string
  description = "The name of the app service plan"
}

variable "app_service_plan_sku" {
  type = object({
    tier = string
    size = string
  })
  description = "The app service plan SKU"
}

# App Service
variable "app_service_name" {
  type        = string
  description = "The name of the app service"
}

variable "app_service_application_insights_name" {
  type        = string
  description = "The name of the application insights resource"
}

# Cosmosdb
variable "cosmosdb_account_name" {
  type        = string
  description = "The name of the cosmosdb acccount"
}

# Traffic Manager
variable "traffic_manager_profile_name" {
  type        = string
  description = "The name of the Azure Traffic Manager Profile"
}

