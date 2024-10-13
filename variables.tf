variable "resource_group_name" {
  description = "(Required) The resource group name to put the virtual machine and all of it's components into."
  type        = string
}

variable "subnet_id" {
  description = "(Required) The subnet id to place the virtual machine on."
  type        = string
}
