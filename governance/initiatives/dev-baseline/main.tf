terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm"; version = "~> 3.80" }
  }
}

data "azurerm_policy_definition" "deny_public_ip_vm" { display_name = "Deny public IP assignment to Virtual Machines" }
data "azurerm_policy_definition" "require_tags" { display_name = "Require environment, owner, and cost-centre tags" }
data "azurerm_policy_definition" "require_tls12" { display_name = "Require TLS 1.2 minimum for Azure Storage Accounts" }

resource "azurerm_policy_set_definition" "dev_baseline" {
  name         = "development-governance-baseline"
  policy_type  = "Custom"
  display_name = "Development Governance Baseline Initiative"
  description  = "Audit-only enforcement -- compliance awareness without operational blocking"
  metadata     = jsonencode({ category = "Governance"; version = "1.0.0" })

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.deny_public_ip_vm.id
    reference_id         = "deny-public-ip-dev"
    parameter_values     = jsonencode({ effect = { value = "Audit" } })
  }
  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.require_tags.id
    reference_id         = "require-tags-dev"
    parameter_values     = jsonencode({ effect = { value = "Audit" } })
  }
  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.require_tls12.id
    reference_id         = "require-tls12-dev"
    parameter_values     = jsonencode({ effect = { value = "Audit" } })
  }
}

output "initiative_id" { value = azurerm_policy_set_definition.dev_baseline.id }
