variable "policy_name" { type = string }
variable "display_name" { type = string }
variable "description" { type = string; default = "" }
variable "policy_mode" { type = string; default = "All" }
variable "category" { type = string; default = "Custom" }
variable "version" { type = string; default = "1.0.0" }
variable "parameters_json" { type = string; default = "" }
variable "policy_rule_json" { type = string }
