variable "location" {
  description = "Azure Region where resources are deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name containing VMs"
  type        = string
}

variable "maintenance_config_name" {
  description = "Name for the maintenance configuration"
  type        = string
  default     = "monthly-updates"
}

variable "week_of_month" {
  description = "Week of the month to apply patching (First, Second, etc.)"
  type        = string
  default     = "First"
}

variable "day_of_week" {
  description = "Day of the week to apply patching (Monday, Tuesday, etc.)"
  type        = string
  default     = "Saturday"
}

variable "start_time" {
  description = "Start time for patching window (HH:MM)"
  type        = string
  default     = "02:00"
}

variable "time_zone" {
  description = "Timezone for patching schedule"
  type        = string
  default     = "UTC"
}
