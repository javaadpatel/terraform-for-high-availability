variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to deploy the traffic manager into"
}

variable "profile_name" {
  type        = string
  description = "The name of the traffic manager profile"
}

variable "primary_endpoint_id" {
  type        = string
  description = "The id of the primary azure app service"
}

variable "secondary_endpoint_id" {
  type        = string
  description = "The id of the primary azure app service"
  default     = "null"
}
