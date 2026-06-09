terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm"; version = "~> 3.80" }
  }
}

resource "azurerm_management_group_policy_assignment" "mg" {
  count                = var.scope_type == "management_group" ? 1 : 0
  name                 = var.assignment_name
  display_name         = var.display_name
  policy_definition_id = var.policy_definition_id
  management_group_id  = var.management_group_id
  description          = var.description

  dynamic "identity" {
    for_each = var.requires_identity ? [1] : []
    content { type = "SystemAssigned" }
  }

  location   = var.requires_identity ? var.location : null
  parameters = var.parameters_json != "" ? var.parameters_json : null
}

output "assignment_id" {
  value = var.scope_type == "management_group" && length(azurerm_management_group_policy_assignment.mg) > 0 ? azurerm_management_group_policy_assignment.mg[0].id : null
}
