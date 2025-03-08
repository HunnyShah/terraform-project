module "resource_group" {
  source              = "./modules/rgroup-n01514804"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "network" {
  source              = "./modules/network-n01514804"
  resource_group_name = module.resource_group.resource_group_name
  location            = var.location
  vnet_name           = "n01514804-VNET"
  subnet_name         = "n01514804-SUBNET"
  nsg_name            = "n01514804-NSG"
}

module "common_services" {
  source               = "./modules/common-n01514804"
  resource_group_name  = module.resource_group.resource_group_name
  location             = var.location
  log_analytics_name   = "n01514804-loganalytics"
  recovery_vault_name  = "n01514804-recoveryvault"
  storage_account_name = "n01514804storage"
}

module "linux_vms" {
  source                      = "./modules/vmlinux-n01514804"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = var.location
  availability_set_name       = "n01514804-linux-avset"
  subnet_id                   = module.network.subnet_id
  admin_username              = "azureuser"
  admin_password              = "SecurePassword123!"
  boot_diagnostics_storage_uri = module.common_services.storage_account_uri

  vm_names = {
    "n01514804-vm1" = "vm1"
    "n01514804-vm2" = "vm2"
  }
}

module "windows_vm" {
  source                      = "./modules/vmwindows-n01514804"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = var.location
  availability_set_name       = "n01514804-windows-avset"
  vm_name                     = "n01514804-winvm"
  vm_count                    = 1
  subnet_id                   = module.network.subnet_id
  admin_username              = "azureuser"
  admin_password              = "SecurePassword123!"
  boot_diagnostics_storage_uri = module.common_services.storage_account_uri
}

module "datadisks" {
  source               = "./modules/datadisk-n01514804"
  resource_group_name  = module.resource_group.resource_group_name
  location             = var.location
  vm_names = {
    "n01514804-vm1"    = module.linux_vms.vm_ids["n01514804-vm1"]
    "n01514804-vm2"    = module.linux_vms.vm_ids["n01514804-vm2"]
    "n01514804-winvm"  = module.windows_vm.vm_id
  }
}
