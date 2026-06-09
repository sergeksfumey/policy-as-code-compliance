# Azure Function: remediate_violations.py
# Triggered by Azure Event Grid compliance state change events
# Handles MEDIUM/LOW severity violations with automated corrective actions
# HIGH/CRITICAL violations route to Logic App for human approval

import logging
import json
from datetime import datetime, timezone
from azure.identity import ManagedIdentityCredential
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.resource import ResourceManagementClient

logger = logging.getLogger(__name__)

SUBSCRIPTION_ID = None
CREDENTIAL = None

def main(event: dict) -> None:
    global SUBSCRIPTION_ID, CREDENTIAL
    import os
    SUBSCRIPTION_ID = os.environ.get("AZURE_SUBSCRIPTION_ID")
    CREDENTIAL = ManagedIdentityCredential()

    resource_id = event.get("data", {}).get("resourceId", "")
    policy_name = event.get("data", {}).get("policyDefinitionName", "")
    compliance_state = event.get("data", {}).get("complianceState", "")
    severity = event.get("data", {}).get("severity", "LOW")

    logger.info(f"Processing: policy={policy_name} resource={resource_id} state={compliance_state}")

    if severity in ("HIGH", "CRITICAL"):
        logger.info("HIGH/CRITICAL -- routing to Logic App approval workflow")
        return

    if compliance_state != "NonCompliant":
        return

    handlers = {
        "deny-public-ip-vm":       remediate_public_ip,
        "require-resource-tags":   remediate_missing_tags,
        "deny-public-blob-access": remediate_public_blob_access,
    }

    handler = handlers.get(policy_name)
    if handler:
        try:
            handler(resource_id)
            log_remediation_action(resource_id, policy_name, "success")
        except Exception as e:
            logger.error(f"Remediation failed: {e}")
            log_remediation_action(resource_id, policy_name, "failed", str(e))
            raise
    else:
        logger.warning(f"No automated handler for policy: {policy_name}")


def remediate_public_ip(resource_id: str) -> None:
    # Removes public IP from VM NIC -- idempotent
    network_client = NetworkManagementClient(CREDENTIAL, SUBSCRIPTION_ID)
    parts = resource_id.split("/")
    rg_name = parts[4]
    nic_name = parts[8]
    nic = network_client.network_interfaces.get(rg_name, nic_name)
    changed = False
    for ip_config in nic.ip_configurations:
        if ip_config.public_ip_address:
            ip_config.public_ip_address = None
            changed = True
    if changed:
        network_client.network_interfaces.begin_create_or_update(rg_name, nic_name, nic).result()
        logger.info(f"Removed public IP from NIC: {nic_name}")
    else:
        logger.info(f"No public IP found on NIC: {nic_name} (already compliant)")


def remediate_missing_tags(resource_id: str) -> None:
    # Applies default tags -- only adds missing, does not overwrite existing values
    resource_client = ResourceManagementClient(CREDENTIAL, SUBSCRIPTION_ID)
    api_version = "2022-09-01"
    resource = resource_client.resources.get_by_id(resource_id, api_version)
    existing_tags = resource.tags or {}
    default_tags = {
        "environment": "untagged",
        "owner":       "platform-team",
        "cost-centre": "unassigned"
    }
    new_tags = {**default_tags, **existing_tags}
    if new_tags != existing_tags:
        resource_client.resources.begin_update_by_id(resource_id, api_version, {"tags": new_tags}).result()
        logger.info(f"Applied default tags: {resource_id}")


def remediate_public_blob_access(resource_id: str) -> None:
    from azure.mgmt.storage import StorageManagementClient
    storage_client = StorageManagementClient(CREDENTIAL, SUBSCRIPTION_ID)
    parts = resource_id.split("/")
    rg_name = parts[4]
    account_name = parts[8]
    storage_client.storage_accounts.update(
        rg_name, account_name, {"allow_blob_public_access": False}
    )
    logger.info(f"Disabled public blob access: {account_name}")


def log_remediation_action(resource_id: str, policy_name: str, status: str, error: str = "") -> None:
    log_entry = {
        "TimeGenerated": datetime.now(timezone.utc).isoformat(),
        "ResourceId": resource_id,
        "PolicyName": policy_name,
        "Status": status,
        "Error": error,
        "TriggeredBy": "automated-policy-remediation"
    }
    logger.info(f"Remediation log: {json.dumps(log_entry)}")
