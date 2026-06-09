data "azurerm_management_group" "production" { name = "production-mg" }
data "azurerm_policy_set_definition" "production_baseline" { display_name = "Production Security Baseline Initiative" }

resource "azurerm_management_group_policy_assignment" "production_baseline" {
  name                 = "prod-security-baseline"
  display_name         = "Production Security Baseline"
  policy_definition_id = data.azurerm_policy_set_definition.production_baseline.id
  management_group_id  = data.azurerm_management_group.production.id
  description          = "Strict Deny enforcement for production"
  identity { type = "SystemAssigned" }
  location = "westeurope"
}

resource "azurerm_role_assignment" "prod_baseline_monitoring" {
  scope                = data.azurerm_management_group.production.id
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_management_group_policy_assignment.production_baseline.identity[0].principal_id
}
