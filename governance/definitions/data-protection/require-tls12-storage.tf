module "require_tls12_storage" {
  source       = "../../modules/policy-definition"
  policy_name  = "require-tls12-storage-governance"
  display_name = "Require TLS 1.2 minimum for Azure Storage Accounts"
  description  = "Prevents storage accounts with TLS below 1.2"
  category     = "Data Protection"
  version      = "1.0.0"

  policy_rule_json = jsonencode({
    if = {
      allOf = [
        { field = "type"; equals = "Microsoft.Storage/storageAccounts" },
        { field = "Microsoft.Storage/storageAccounts/minimumTlsVersion"; notEquals = "TLS1_2" }
      ]
    }
    then = { effect = "[parameters('effect')]" }
  })

  parameters_json = jsonencode({
    effect = { type = "String"; defaultValue = "Deny"; allowedValues = ["Audit","Deny"]; metadata = { displayName = "Effect" } }
  })
}

output "require_tls12_storage_id" { value = module.require_tls12_storage.policy_definition_id }
