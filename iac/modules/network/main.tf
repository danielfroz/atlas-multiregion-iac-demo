resource "azurerm_virtual_network" "vnet" {
  name = "${var.env}-${var.location}-vnet"
  location = var.location
  resource_group_name = var.resource_group
  address_space = var.vnet_address_space
  tags = {
    environment = var.env
  }
}

resource "azurerm_subnet" "subnet" {
  name = "${var.env}-${var.location}-subnet"
  resource_group_name = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = var.subnet_address_prefixes
  default_outbound_access_enabled = false
}

resource "azurerm_network_security_group" "nsg" {
  name = "${var.env}-${var.location}-nsg"
  location = var.location
  resource_group_name = var.resource_group
  tags = {
    environment = var.env
  }
}

resource "azurerm_network_security_rule" "nsg-rule-web" {
  name = "${var.env}-${var.location}-nsg-rule-in-web"
  resource_group_name = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "80"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

# 
# You shall remove this rule in real production deployments. 
# Since we're working with a Demo which we may delete all resources after the presentation, then it is fine...
# 
resource "azurerm_network_security_rule" "nsg-rule-ssh" {
  name = "${var.env}-${var.location}-nsg-rule-in-ssh"
  resource_group_name = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority = 101
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  # customize this source - allowing only access from your IP address
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "nsg-rule-api" {
  name = "${var.env}-${var.location}-nsg-rule-in-api"
  resource_group_name = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority = 102
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "3000"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_subnet_network_security_group_association" "subnet-nsg" {
  subnet_id = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

