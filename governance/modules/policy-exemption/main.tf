terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm"; version = "~> 3.80" }
  }
}

resource "azurerm_resource_policy_exemption" "main" {
  name                 = var.exemption_name
  resource_id          = var.resource_id
  policy_assignment_id = var.policy_assignment_id
  exemption_category   = var.exemption_category
  expires_on           = var.expires_on
  description          = var.description
}

output "exemption_id" { value = azurerm_resource_policy_exemption.main.id }
output "expires_on" { value = var.expires_on }
