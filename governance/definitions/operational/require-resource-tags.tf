module "require_resource_tags" {
  source       = "../../modules/policy-definition"
  policy_name  = "require-resource-tags-governance"
  display_name = "Require environment, owner, and cost-centre tags"
  description  = "All resources must have environment, owner, cost-centre tags"
  category     = "Tags"
  version      = "1.0.0"
  policy_mode  = "Indexed"

  policy_rule_json = jsonencode({
    if = {
      anyOf = [
        { field = "tags['environment']"; exists = "false" },
        { field = "tags['owner']"; exists = "false" },
        { field = "tags['cost-centre']"; exists = "false" }
      ]
    }
    then = { effect = "[parameters('effect')]" }
  })

  parameters_json = jsonencode({
    effect = { type = "String"; defaultValue = "Deny"; allowedValues = ["Audit","Deny"]; metadata = { displayName = "Effect" } }
  })
}

output "require_tags_policy_id" { value = module.require_resource_tags.policy_definition_id }
