resource "azurerm_cosmosdb_account" "main" {
  name                          = "cosmos-mcp-test-dev"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  offer_type                    = "Standard"
  public_network_access_enabled = false
  local_authentication_enabled  = false
  tags                          = local.common_tags

  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
}

resource "azurerm_redis_cache" "main" {
  name                          = "redis-mcp-test-dev"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  sku_name                      = "Standard"
  family                        = "C"
  capacity                      = 1
  minimum_tls_version           = "1.2"
  non_ssl_port_enabled          = false
  public_network_access_enabled = false
  tags                          = local.common_tags
  redis_configuration {
    active_directory_authentication_enabled = true
  }
}

resource "azurerm_cosmosdb_sql_database" "chat" {
  name                = "chat"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
}

resource "azurerm_cosmosdb_sql_container" "messages" {
  name                  = "messages"
  resource_group_name   = azurerm_resource_group.main.name
  account_name          = azurerm_cosmosdb_account.main.name
  database_name         = azurerm_cosmosdb_sql_database.chat.name
  partition_key_paths   = ["/conversationId"]
  partition_key_version = 2

  autoscale_settings {
    max_throughput = 1000
  }
}

resource "azurerm_cosmosdb_sql_container" "conversations" {
  name                  = "conversations"
  resource_group_name   = azurerm_resource_group.main.name
  account_name          = azurerm_cosmosdb_account.main.name
  database_name         = azurerm_cosmosdb_sql_database.chat.name
  partition_key_paths   = ["/userId"]
  partition_key_version = 2

  autoscale_settings {
    max_throughput = 1000
  }
}

resource "azurerm_cosmosdb_sql_role_assignment" "chat_identity" {
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  principal_id        = azurerm_user_assigned_identity.main.principal_id
  role_definition_id  = "${azurerm_cosmosdb_account.main.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  scope               = azurerm_cosmosdb_account.main.id
}

resource "azurerm_redis_cache_access_policy_assignment" "chat_identity" {
  name               = "chat-identity"
  access_policy_name = "Data Contributor"
  object_id          = azurerm_user_assigned_identity.main.principal_id
  object_id_alias    = azurerm_user_assigned_identity.main.name
  redis_cache_id     = azurerm_redis_cache.main.id
}
