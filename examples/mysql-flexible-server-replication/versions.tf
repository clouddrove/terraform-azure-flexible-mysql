# Terraform version
terraform {
  required_version = ">= 1.7.8"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.9.0"
    }
  }
}
