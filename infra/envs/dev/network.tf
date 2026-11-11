resource "azurerm_virtual_network" "main" {
  name                = "vnet-mcp-test-dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "main" {
  name                            = "snet-mcp-test-dev-apps"
  resource_group_name             = azurerm_virtual_network.main.resource_group_name
  virtual_network_name            = azurerm_virtual_network.main.name
  address_prefixes                = ["10.0.0.0/23"]
  default_outbound_access_enabled = false
  delegation {
    name = "app-environments"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "main_2" {
  name                            = "snet-mcp-test-dev-pe"
  resource_group_name             = azurerm_virtual_network.main.resource_group_name
  virtual_network_name            = azurerm_virtual_network.main.name
  address_prefixes                = ["10.0.2.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "afd-mcp-test-dev"
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone" "vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vault" {
  name                 = "link-mcp-test-dev-vault"
  private_dns_zone_id  = azurerm_private_dns_zone.vault.id
  virtual_network_id   = azurerm_virtual_network.main.id
  registration_enabled = false
  tags                 = local.common_tags
}

resource "azurerm_private_endpoint" "vault" {
  name                = "pe-mcp-test-dev-vault"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.main_2.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "vault"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.vault.id]
  }
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                 = "link-mcp-test-dev-blob"
  private_dns_zone_id  = azurerm_private_dns_zone.blob.id
  virtual_network_id   = azurerm_virtual_network.main.id
  registration_enabled = false
  tags                 = local.common_tags
}

resource "azurerm_private_endpoint" "blob" {
  name                = "pe-mcp-test-dev-blob"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.main_2.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "blob"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

resource "azurerm_private_dns_zone" "registry" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "registry" {
  name                 = "link-mcp-test-dev-registry"
  private_dns_zone_id  = azurerm_private_dns_zone.registry.id
  virtual_network_id   = azurerm_virtual_network.main.id
  registration_enabled = false
  tags                 = local.common_tags
}

resource "azurerm_private_endpoint" "registry" {
  name                = "pe-mcp-test-dev-registry"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.main_2.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "registry"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.registry.id]
  }
}

resource "azurerm_private_endpoint" "main" {
  name                = "pe-mcp-test-dev-cosmos"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.main_2.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "default"
    private_connection_resource_id = azurerm_cosmosdb_account.main.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.cosmos.id]
  }
}

resource "azurerm_private_endpoint" "main_2" {
  name                = "pe-mcp-test-dev-redis"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.main_2.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "default"
    private_connection_resource_id = azurerm_redis_cache.main.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis.id]
  }
}

resource "azurerm_private_endpoint" "main_3" {
  name                = "pe-mcp-test-dev-servicebus"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.main_2.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "default"
    private_connection_resource_id = azurerm_servicebus_namespace.main.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.servicebus.id]
  }
}

resource "azurerm_private_dns_zone" "cosmos" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone" "redis" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone" "servicebus" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos" {
  name                 = "link-mcp-test-dev-cosmos"
  private_dns_zone_id  = azurerm_private_dns_zone.cosmos.id
  registration_enabled = false
  virtual_network_id   = azurerm_virtual_network.main.id
  tags                 = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  name                 = "link-mcp-test-dev-redis"
  private_dns_zone_id  = azurerm_private_dns_zone.redis.id
  registration_enabled = false
  virtual_network_id   = azurerm_virtual_network.main.id
  tags                 = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "servicebus" {
  name                 = "link-mcp-test-dev-servicebus"
  private_dns_zone_id  = azurerm_private_dns_zone.servicebus.id
  registration_enabled = false
  virtual_network_id   = azurerm_virtual_network.main.id
  tags                 = local.common_tags
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "fde-mcp-test-dev-chat"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  enabled                  = true
  tags                     = local.common_tags
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name                     = "og-chat-api"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  session_affinity_enabled = true

  health_probe {
    interval_in_seconds = 30
    path                = "/healthz"
    protocol            = "Https"
    request_type        = "GET"
  }
  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "main" {
  name                           = "origin-chat-api"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.main.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_container_app.main.ingress[0].fqdn
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_container_app.main.ingress[0].fqdn
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "route-chat"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.main.id]
  enabled                       = true
  forwarding_protocol           = "HttpsOnly"
  https_redirect_enabled        = true
  link_to_default_domain        = true
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
}
