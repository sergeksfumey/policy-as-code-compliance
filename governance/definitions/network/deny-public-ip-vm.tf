module "deny_public_ip_vm" {
  source       = "../../modules/policy-definition"
  policy_name  = "deny-public-ip-vm"
  display_name = "Deny public IP assignment to Virtual Machines"
  description  = "Prevents VMs from having public IPs -- enforces Bastion/VPN as only admin path"
  category     = "Network"
  version      = "1.0.0"

  policy_rule_json = jsonencode({
    if = {
      allOf = [
        { field = "type"; equals = "Microsoft.Network/networkInterfaces" },
        { not = { field = "Microsoft.Network/networkInterfaces/ipconfigurations[*].publicIpAddress.id"; exists = "false" } }
      ]
    }
    then = { effect = "[parameters('effect')]" }
  })

  parameters_json = jsonencode({
    effect = { type = "String"; defaultValue = "Deny"; allowedValues = ["Audit","Deny","Disabled"]; metadata = { displayName = "Effect" } }
  })
}

output "deny_public_ip_vm_id" { value = module.deny_public_ip_vm.policy_definition_id }
