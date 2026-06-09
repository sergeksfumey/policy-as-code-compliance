terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm"; version = "~> 3.80" }
  }
}

resource "azurerm_policy_definition" "main" {
  name         = var.policy_name
  policy_type  = "Custom"
  mode         = var.policy_mode
  display_name = var.display_name
  description  = var.description

  metadata    = jsonencode({ category = var.category; version = var.version })
  parameters  = var.parameters_json != "" ? var.parameters_json : null
  policy_rule = var.policy_rule_json
}

output "policy_definition_id" { value = azurerm_policy_definition.main.id }
output "policy_name" { value = azurerm_policy_definition.main.name }
