# Architecture Notes -- Policy-as-Code Compliance Platform

## Management Group Hierarchy

Policy propagation time: up to 30 minutes for new assignments to reach all child subscriptions.

Hierarchy:
- enterprise-mg: root, universal baseline
- platform-mg: identity + connectivity subscriptions
- production-mg: all production workload subscriptions (Deny effects)
- test-mg: test/staging subscriptions (moderate effects)
- development-mg: dev subscriptions (Audit effects)
- sandbox-mg: exploration, minimal governance

## Policy Effect Selection

Deny: blocks resource deployment at ARM layer -- use for security controls that must never be violated in prod
DeployIfNotExists: creates required configurations async after resource deployment -- use for diagnostics, tags
Audit: reports without blocking -- use for dev environments and initial roll-out
Modify: adds/replaces resource properties -- use for tag enforcement on existing resources

IMPORTANT: Deny effect is NOT evaluated by terraform plan.
Plan success does NOT guarantee apply success in Policy-governed environments.
Always test in Audit mode first before switching to Deny in production.

## Exemption Governance

Rules:
- No permanent exemptions -- all require expires_on
- Maximum duration: 2 years (90 days typical)
- All require justification with ticket reference
- Exemptions are version-controlled -- no portal-created exemptions
- Quarterly review mandatory

Creating exemptions:
1. Raise JIRA/GitHub ticket with justification
2. Write Terraform exemption resource with expires_on and description
3. PR with governance-team + security-team (for prod) reviewers
4. After merge, verify: az policy exemption show --name <name>

## Resource Graph Throttling

Standard tier: ~15 queries per 5 seconds per tenant
Power BI mitigation: cache results in Azure Storage, schedule refresh off-peak
Do NOT use direct Power BI -> Resource Graph without caching at enterprise scale.
