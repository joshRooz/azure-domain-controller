resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.region
}

resource "azurerm_public_ip" "this" {
  name                = var.public_ip_address_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  availability_zone   = "No-Zone" #local.az_support_by_region[lower(var.region)] ? "Zone-Redundant" : "No-Zone"
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.dns_prefix
}

resource "azurerm_availability_set" "this" {
  name                        = var.ad_availability_set_name
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  platform_fault_domain_count = 2
}

data "http" "tf_client" {
  url = "https://api.ipify.org"
}

resource "azurerm_network_security_group" "this" {
  name                = var.ad_network_security_group_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "allow-rdp-from-tfclient"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = data.http.tf_client.body
    destination_address_prefix = var.ad_subnet_address_prefix
  }

  security_rule {
    name                       = "allow-winrm-from-tfclient"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = data.http.tf_client.body
    destination_address_prefix = var.ad_subnet_address_prefix
  }
}

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.virtual_network_address_range]
}

resource "azurerm_subnet" "this" {
  name                 = var.ad_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.ad_subnet_address_prefix]
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}
resource "azurerm_network_interface" "this" {
  name                          = var.ad_nic_name
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  enable_accelerated_networking = true # Adds Melanox NIC when enabled

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.ad_subnet_address_prefix, 4)
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  name                = var.ad_virtual_machine_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  availability_set_id = azurerm_availability_set.this.id
  timezone            = var.ad_virtual_machine_timezone
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.this.id]

  os_disk {
    name                 = "${var.ad_virtual_machine_name}-osDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows_server_version
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "this" {
  name                 = "${var.ad_virtual_machine_name}-dataDisk"
  location             = azurerm_resource_group.this.location
  resource_group_name  = azurerm_resource_group.this.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  managed_disk_id    = azurerm_managed_disk.this.id
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  lun                = 0
  caching            = "None"
}

# ideally the DSC zip would become an artifact or release via a CI/CD process
# and not reside in source control as a zip
resource "azurerm_virtual_machine_extension" "this" {
  name                       = "ADDomainServices-${var.dsc_function}"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.80"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    wmfVersion = "latest"
    configuration = {
      url      = "${trimsuffix(var._artifacts_location, "/")}/DSC/ADDomainServices.zip"
      script   = "ADDomainServices.ps1"
      function = var.dsc_function
    }
    configurationArguments = {
      DomainName = var.domain_name
    }
  })

  protected_settings = jsonencode({
    configurationArguments = {
      AdminCreds = {
        userName = var.admin_username
        password = var.admin_password
      }
    }
  })
}

resource "azurerm_lb" "this" {
  name                = var.ad_load_balancer_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.ad_load_balancer_frontend_name
    availability_zone    = "No-Zone"
    public_ip_address_id = azurerm_public_ip.this.id
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  name            = var.ad_load_balancer_backend_name
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_backend_address_pool_address" "this" {
  name                    = var.ad_virtual_machine_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id
  virtual_network_id      = azurerm_virtual_network.this.id
  ip_address              = azurerm_network_interface.this.private_ip_address
}

resource "azurerm_lb_nat_rule" "rdp" {
  name                = var.ad_remote_desktop_nat_name
  resource_group_name = azurerm_resource_group.this.name

  loadbalancer_id                = azurerm_lb.this.id
  frontend_ip_configuration_name = var.ad_load_balancer_frontend_name
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
}

resource "azurerm_lb_nat_rule" "rmgmt" {
  name                = "adWinRM"
  resource_group_name = azurerm_resource_group.this.name

  loadbalancer_id                = azurerm_lb.this.id
  frontend_ip_configuration_name = var.ad_load_balancer_frontend_name
  protocol                       = "Tcp"
  frontend_port                  = 5985
  backend_port                   = 5985
}

resource "azurerm_lb_outbound_rule" "this" {
  name                    = "OutboundRule"
  resource_group_name     = azurerm_resource_group.this.name
  loadbalancer_id         = azurerm_lb.this.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id

  frontend_ip_configuration {
    name = var.ad_load_balancer_frontend_name
  }
}

resource "azurerm_network_interface_nat_rule_association" "rdp" {
  network_interface_id  = azurerm_network_interface.this.id
  ip_configuration_name = coalesce(azurerm_network_interface.this.ip_configuration.*.name...)
  nat_rule_id           = azurerm_lb_nat_rule.rdp.id
}

resource "azurerm_network_interface_nat_rule_association" "rmgmt" {
  network_interface_id  = azurerm_network_interface.this.id
  ip_configuration_name = coalesce(azurerm_network_interface.this.ip_configuration.*.name...)
  nat_rule_id           = azurerm_lb_nat_rule.rmgmt.id
}

resource "azurerm_virtual_network_dns_servers" "this" {
  virtual_network_id = azurerm_virtual_network.this.id
  dns_servers        = [azurerm_network_interface.this.private_ip_address]

  depends_on = [
    azurerm_virtual_machine_extension.this
  ]
}