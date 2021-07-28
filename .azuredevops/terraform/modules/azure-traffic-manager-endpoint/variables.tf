variable "name" {
  type        = string
  description = "The name of the endpoint"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group that has the traffic manager profile"
}

variable "profile_name" {
  type        = string
  description = "The name of the traffic manager profile"
}

variable "endpoint_id" {
  type        = string
  description = "The endpoint id of the Azure resource"
}

variable "priority" {
  type        = number
  description = "The priority for this endpoint"
}
