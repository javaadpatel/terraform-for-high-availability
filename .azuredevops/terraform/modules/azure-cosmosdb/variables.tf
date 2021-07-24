
variable "resource_group_name" {
  type        = string
  description = "The resource group that db should be deployed into"
}

variable "primary_location" {
  type        = string
  description = "The primary region for the db"
}


variable "secondary_location" {
  type        = string
  description = "The primary region for the db"
}

variable "account_name" {
type= string
description = "The name of the cosmosdb account"
}