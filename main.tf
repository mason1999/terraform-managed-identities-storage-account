// Note: Subnet is assumed to have a range of 10.0.0.0/24
locals {
  resource_group_name = var.resource_group_name
  location            = "australiaeast"
  suffix              = "example-1"
  subnet_id           = var.subnet_id
  admin_username      = "testuser"
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "managed-identity-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = local.location
}

resource "azurerm_storage_account" "example" {
  name                     = "myteststore0000000000"
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_public_ip" "example" {
  name                = "public-ip-${local.suffix}"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "example" {
  name                = "nic-${local.suffix}"
  location            = local.location
  resource_group_name = local.resource_group_name

  # Ip configuration
  ip_configuration {
    name                          = "ip-configuration-${local.suffix}"
    subnet_id                     = local.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.4"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                            = "vm-${local.suffix}"
  resource_group_name             = local.resource_group_name
  location                        = local.location
  size                            = "Standard_DS1_v2"
  admin_username                  = local.admin_username
  admin_password                  = "WeakPassword123"
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.example.id]

  os_disk {
    name                 = "ubuntu-disk-${local.suffix}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }
}

data "template_file" "init" {
  template = file("${path.module}/init.sh")
  vars = {
    OPTARG = ""
  }
}

resource "azurerm_virtual_machine_extension" "example" {
  name                 = "ubuntu-init-script"
  virtual_machine_id   = azurerm_linux_virtual_machine.example.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
{
  "commandToExecute": "echo ${base64encode(data.template_file.init.template)} > /home/buffer_64.txt && base64 --decode /home/buffer_64.txt > /home/init.sh && rm /home/buffer_64.txt && chmod u+x /home/init.sh && bash /home/init.sh -r ${local.admin_username}"
}
SETTINGS
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.example.principal_id
}
