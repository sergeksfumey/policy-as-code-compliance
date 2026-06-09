# Remediation Operational Runbook

Automated (MEDIUM/LOW): Event Grid -> Azure Function, no human intervention
Target MTTR: tags 15 min, public blob 2 min, diagnostic settings 30 min

Approval-required (HIGH/CRITICAL): Event Grid -> Logic App -> approval workflow
Timeout: 4 hours then escalates to on-call
Approve via Teams card or email button

Bulk remediation (on-demand):
1. Review non-compliant resource count via Resource Graph
2. Schedule maintenance window
3. Run Invoke-BulkRemediation.ps1 with PolicyAssignmentId and ApprovalTicket
4. Monitor: Azure Portal > Policy > Remediation

Remediation failure response:
1. Check dead letter queue on Event Grid subscription
2. Review Function App logs
3. Common failures: insufficient permissions, resource locked, unsupported resource type
4. Open JIRA for engineering team if automation cannot be fixed quickly
