resource "azurerm_resource_group" "main" {
  name     = "rg-mcp-test-dev"
  location = var.location
  tags     = local.common_tags
}
