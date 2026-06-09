variable "assignment_name" { type = string }
variable "display_name" { type = string }
variable "description" { type = string; default = "" }
variable "policy_definition_id" { type = string }
variable "scope_type" { type = string; default = "management_group" }
variable "management_group_id" { type = string; default = "" }
variable "subscription_id" { type = string; default = "" }
variable "requires_identity" { type = bool; default = false }
variable "location" { type = string; default = "westeurope" }
variable "remediation_role" { type = string; default = "" }
variable "parameters_json" { type = string; default = "" }
