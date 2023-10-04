variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
  default     = "Sales-Lab"
}

variable "resource_group_location" {
  description = "The location of the Azure resource group"
  type = string
  default = "westus2"
}

variable "admin_username" {
  description = "The admin username for the AKS cluster."
  type        = string
  default     = "sa_admin"
}

variable "cluster_name" {
  description = "The name for the AKS cluster."
  type        = string
  default     = "qwerty"
}

variable "location" {
  description = "The Azure region in which to create the resources."
  type        = string
  default     = "westus2"
}

variable "log_retention_in_days" {
  description = "The number of days to retain logs."
  type        = number
  default     = 365
}

variable "spotinst_token" {
  description = "Spotinst API token."
  type        = string
  default     = "abc" # Replace with your actual token
}

variable "spotinst_account" {
  description = "Spotinst account identifier."
  type        = string
  default     = "act-xyz" #  Repalce Azure Account from Sales Lab
}


