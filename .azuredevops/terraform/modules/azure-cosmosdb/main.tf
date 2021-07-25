resource "azurerm_cosmosdb_account" "db" {
  name                = var.account_name
  location            = var.primary_location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = var.secondary_location
    failover_priority = 1
  }

  geo_location {
    location          = var.primary_location
    failover_priority = 0
  }
}

output "endpoint" {
  value     = azurerm_cosmosdb_account.db.endpoint
  sensitive = false
}
