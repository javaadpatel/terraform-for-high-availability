resource_group_name = "high-availability"
primary_location    = "West Europe"
secondary_location  = "North Europe"

app_service_plan_name = "high-availability"
app_service_plan_sku = {
  tier = "Standard"
  size = "S1"
}

app_service_name                      = "high-availability-terraform-javaad"
app_service_application_insights_name = "high-availability-terraform-javaad"
cosmosdb_account_name                 = "high-availability-cosmosdb-javaad"
