[CmdletBinding()]
param (
    [Parameter(Mandatory)][string]$PolicyAssignmentId,
    [string]$ResourceGroupFilter = "",
    [Parameter(Mandatory)][string]$ApprovalTicket
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Log { param([string]$Message, [string]$Level = "INFO"); Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message" }

Write-Log "=== BULK POLICY REMEDIATION === Ticket: $ApprovalTicket"
Connect-AzAccount -Identity

$remediationName = "remediation-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$params = @{ Name = $remediationName; PolicyAssignmentId = $PolicyAssignmentId }
if ($ResourceGroupFilter) { $params.ResourceGroupName = $ResourceGroupFilter }

$remediation = Start-AzPolicyRemediation @params
Write-Log "Task created: $($remediation.Id)"

$maxWait = 60; $elapsed = 0
do {
    Start-Sleep -Seconds 30; $elapsed += 0.5
    $status = Get-AzPolicyRemediation -Id $remediation.Id
    Write-Log "Status: $($status.ProvisioningState) | Resources: $($status.ResourceCount) | Elapsed: $elapsed min"
} while ($status.ProvisioningState -notin @("Succeeded","Failed","Canceled") -and $elapsed -lt $maxWait)

Write-Log "Final: $($status.ProvisioningState) | Succeeded: $($status.SuccessfulResourceCount) | Failed: $($status.FailedResourceCount)"
