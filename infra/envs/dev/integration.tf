resource "azurerm_servicebus_namespace" "main" {
  name                          = "sb-mcp-test-dev"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  sku                           = "Premium"
  capacity                      = 1
  premium_messaging_partitions  = 1
  minimum_tls_version           = "1.2"
  local_auth_enabled            = false
  public_network_access_enabled = false
  tags                          = local.common_tags
}

resource "azurerm_servicebus_queue" "chat_events" {
  name                                 = "chat-events"
  dead_lettering_on_message_expiration = true
  max_delivery_count                   = 10
  namespace_id                         = azurerm_servicebus_namespace.main.id
}
