/**
  * ## TFE Workspace
  *
  * This module creates a TFE workspace
  */

terraform {
  required_version = ">= 1.3"
  required_providers {
    tfe = {
      version = "~> 0.39.0"
    }
    local = {
      version = "~> 2.2.3"
    }
  }
  backend "local" {}
}

variable "cloud_organization" {
  description = "value of the organization name"
  type        = string
  default     = ""
}

variable "workspace" {
  description = "value of the workspace name"
  type        = string
}

variable "workspace_tags" {
  description = "value of the workspace tags"
  type        = list(string)
  default     = ["tf"]
}

variable "workspace_description" {
  description = "value of the workspace description"
  type        = string
  default     = ""
}

data "tfe_workspace_ids" "app" {
  names        = [var.tfe_workspace_name != "" ? var.tfe_workspace_name : ""]
  organization = var.tfe_organization_name
}


output "names" {
  value = data.tfe_workspace_ids.app.full_names
}

resource "tfe_workspace" "workspace" {
  count             = length(data.tfe_workspace_ids.app.ids) == 0 && var.workspace != "" ? 1 : 0
  name              = var.workspace
  organization      = var.cloud_organization
  description       = var.workspace_description
  tag_names         = var.workspace_tags
  execution_mode    = "local"
}

resource "local_file" "backend" {
  content = templatefile("backend.tftpl", {
    organization = var.cloud_organization
    workspace    = var.workspace
  })
  filename = "backend.tf"
}
