# General
variable "resource_group_name" {
  type        = string
  description = "The resource group that app service should be deployed into"
}

variable "location" {
  type        = string
  description = "The region that the app service should be deployed into"
}

# Resources
## Application Insights
variable "application_insights_name" {
  type        = string
  description = "The name of the application insights resource associated with the app service"
}

variable "application_insights_type" {
  type        = string
  description = "The type of the application insights resource associated with the function app"
  default     = "web"
}

## App Service Plan
variable "app_service_plan_name" {
  type        = string
  description = "The name of the app service plan"
}

variable "app_service_plan_sku" {
  type = object({
    tier = string
    size = string
  })
  description = "The sku of the app service plan"
}

## App Service
variable "app_service_name" {
  type        = string
  description = "The name of the azure app service"
}

variable "application_settings" {
  description = "The application settings for the function app"
  default     = {}
}

