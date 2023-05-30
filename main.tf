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

variable "tfe_organization_name" {
  description = "value of the organization name"
  type        = string
  default     = ""
}

variable "tfe_workspace_name" {
  description = "value of the workspace name"
  type        = string
}

variable "tfe_workspace_tags" {
  description = "value of the workspace tags"
  type        = list(string)
  default     = ["tf"]
}

variable "tfe_workspace_description" {
  description = "value of the workspace description"
  type        = string
  default     = ""
}

variable "tfe_backend_path" {
  description = "value of the backend path"
  type        = string
  default     = "./"
}

data "tfe_workspace_ids" "app" {
  names        = [var.tfe_workspace_name != "" ? var.tfe_workspace_name : ""]
  organization = var.tfe_organization_name
}


# output "names" {
#   value = data.tfe_workspace_ids.app.full_names
# }

resource "tfe_workspace" "workspace" {
  count          = length(data.tfe_workspace_ids.app.ids) == 0 && var.tfe_workspace_name != "" ? 1 : 0
  name           = var.tfe_workspace_name
  organization   = var.tfe_organization_name
  description    = var.tfe_workspace_description
  tag_names      = var.tfe_workspace_tags
  # execution_mode = "local"
}

resource "local_file" "backend" {
  content = templatefile("backend.tftpl", {
    organization = var.tfe_organization_name
    workspace    = var.tfe_workspace_name
  })
  filename = "${var.tfe_backend_path}/backend.tf"
}
