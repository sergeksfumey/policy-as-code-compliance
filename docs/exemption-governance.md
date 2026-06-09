# Exemption Governance Guide

No permanent exemptions. All require expiry date, justification, and ticket reference.

Categories:
- Waiver: organisation accepts risk -- approval: governance team + resource owner
- Mitigated: alternative control provides equivalent protection -- approval: governance + security team

Terraform exemption pattern:
  module "exemption_example" {
    source               = "../../modules/policy-exemption"
    exemption_name       = "example-dev-exemption-2026"
    resource_id          = "<resource_id>"
    policy_assignment_id = "<assignment_id>"
    exemption_category   = "Waiver"
    expires_on           = "2026-06-30T00:00:00Z"
    description          = "Reason. JIRA-1234. Approved by: security-team. Expires 2026-06-30."
  }

Quarterly review:
  az policy exemption list --query "[].{name:name,expires:expiresOn,desc:description}" --output table
