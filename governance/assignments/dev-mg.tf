data "azurerm_management_group" "development" { name = "development-mg" }
data "azurerm_policy_set_definition" "dev_baseline" { display_name = "Development Governance Baseline Initiative" }

resource "azurerm_management_group_policy_assignment" "dev_baseline" {
  name                 = "dev-governance-baseline"
  display_name         = "Development Governance Baseline"
  policy_definition_id = data.azurerm_policy_set_definition.dev_baseline.id
  management_group_id  = data.azurerm_management_group.development.id
  description          = "Audit-only awareness for development"
}
