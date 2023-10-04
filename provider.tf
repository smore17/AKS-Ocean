terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.40.0"
    }
    spotinst = {
      source = "spotinst/spotinst"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}
