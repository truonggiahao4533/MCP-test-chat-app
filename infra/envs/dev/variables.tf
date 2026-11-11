variable "location" {
  description = "Azure region for every resource in this environment."
  type        = string
  default     = "westeurope"
}

variable "tenant_id" {
  description = "Entra ID tenant that owns Key Vaults and database sign-in. Replace before deploying."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}
