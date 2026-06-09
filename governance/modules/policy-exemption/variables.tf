variable "exemption_name" { type = string }
variable "resource_id" { type = string }
variable "policy_assignment_id" { type = string }
variable "exemption_category" {
  type    = string
  default = "Waiver"
  validation {
    condition     = contains(["Waiver", "Mitigated"], var.exemption_category)
    error_message = "Must be Waiver or Mitigated"
  }
}
variable "expires_on" {
  type        = string
  description = "Mandatory expiry ISO 8601 (e.g. 2026-12-31T00:00:00Z). No permanent exemptions."
}
variable "description" { type = string }
