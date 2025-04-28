provider "azurerm" {
  features {}
}

# Maintenance Configuration for Monthly Updates
resource "azurerm_maintenance_configuration" "monthly_update_config" {
  name                = var.maintenance_config_name
  resource_group_name = var.resource_group_name
  location            = var.location

  maintenance_scope   = "InGuestPatch"

  install_patches {
    reboot = "IfRequired"

    windows {
      classifications_to_include = ["Critical", "Security"]
    }

    linux {
      classifications_to_include = ["Critical", "Security"]
    }
  }

  recurring_schedule {
    frequency         = "Monthly"
    interval          = 1
    week_of_month     = var.week_of_month
    day_of_week       = var.day_of_week
    start_time        = var.start_time
    time_zone         = var.time_zone
    duration          = "04:00"
  }
}

# Find VMs with specific tag
data "azurerm_resources" "vms_with_patching_tag" {
  type = "Microsoft.Compute/virtualMachines"

  required_tags = {
    patching = "enabled"
  }
}

# Assign Maintenance Configuration to matching VMs
resource "azurerm_maintenance_assignment_virtual_machine" "assign_update" {
  for_each = { for vm in data.azurerm_resources.vms_with_patching_tag.resources : vm.name => vm }

  name                           = "assign-monthly-updates-${each.key}"
  maintenance_configuration_id   = azurerm_maintenance_configuration.monthly_update_config.id
  virtual_machine_id             = each.value.id
  location                       = each.value.location
  resource_group_name            = each.value.resource_group_name
}

# Add Azure Update Manager Policy (Patch Assignment)
resource "azurerm_guest_patch_assignment" "patch_assignment" {
  for_each = { for vm in data.azurerm_resources.vms_with_patching_tag.resources : vm.name => vm }

  name                = "patch-assignment-${each.key}"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  virtual_machine_id  = each.value.id

  patch_configuration {
    patch_mode                   = "AutomaticByPlatform"
    maintenance_configuration_id = azurerm_maintenance_configuration.monthly_update_config.id
    reboot_setting                = "IfRequired"
  }
}
