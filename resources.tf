# VNET definition

resource "azurerm_virtual_network" "frontend" {
  name                = "ProtectedFrontend"
  address_space       = ["10.20.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_virtual_network" "dmz01" {
  name                = "ProtectedDmz01"
  address_space       = ["10.30.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

# VNET Peering

resource "azurerm_virtual_network_peering" "peer1" {
  name                         = "frontend-to-dmz01"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name         = "${azurerm_virtual_network.frontend.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.dmz01.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "peer2" {
  name                         = "dmz01-to-frontend"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name         = "${azurerm_virtual_network.dmz01.name}"
  remote_virtual_network_id    = "${azurerm_virtual_network.frontend.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Subnet deffinitions

resource "azurerm_subnet" "management" {
  name                 = "management"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.frontend.name}"
  address_prefix       = "10.20.0.0/24"

}

resource "azurerm_subnet" "external" {
  name                 = "external"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.frontend.name}"
  address_prefix       = "10.20.1.0/24"

}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.frontend.name}"
  address_prefix       = "10.20.2.0/24"
}

resource "azurerm_subnet" "dmz01" {
  name                 = "dmz01"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.dmz01.name}"
  address_prefix       = "10.30.1.0/24"
}


# Public IPs for publications

resource "azurerm_public_ip" "fgvm01-pip" {
  name                         = "fgvm01-pip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  public_ip_address_allocation = "static"
  sku                          = "Standard"
}

resource "azurerm_public_ip" "fgvm02-pip" {
  name                         = "fgvm02-pip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  public_ip_address_allocation = "static"
  sku                          = "Standard"
}

# Public  IPs for Management

resource "azurerm_public_ip" "fgvm01-mgmt" {
  name                         = "fgvm01-mgmt"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  public_ip_address_allocation = "static"
  sku                          = "Standard"
}

resource "azurerm_public_ip" "fgvm02-mgmt" {
  name                         = "fgvm02-mgmt"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  public_ip_address_allocation = "static"
  sku                          = "Standard"
}

resource "azurerm_public_ip" "fmg-mgmt" {
  name                         = "fmg-mgmt"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  public_ip_address_allocation = "static"
  sku                          = "Standard"
}


resource "azurerm_network_security_group" "nsg-external" {
  name                = "nsg-external"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutAll"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg-management" {
  name                = "nsg-management"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutAll"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_security_group" "nsg-internal" {
  name                = "nsg-internal"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  security_rule {
    name                       = "AllowInAll"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutAll"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.20.2.0/24"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "10.20.2.0/24"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1003
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "10.20.2.0/24"
  }

  security_rule {
    name                       = "ToFrontendOut"
    priority                   = 1005
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.20.2.0/24"
  }

  security_rule {
    name                       = "FromInternalLBIn"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.20.1.10/32"
    destination_address_prefix = "*"
  }
}

# Security Groups mapping

resource "azurerm_subnet_network_security_group_association" "secgroup2internal" {
  subnet_id                 = "${azurerm_subnet.internal.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg-internal.id}"
}

resource "azurerm_subnet_network_security_group_association" "secgroup2external" {
  subnet_id                 = "${azurerm_subnet.external.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg-external.id}"
}

resource "azurerm_subnet_network_security_group_association" "secgroup2management" {
  subnet_id                 = "${azurerm_subnet.management.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg-management.id}"
}


resource "azurerm_availability_set" "fgtAVSet" {
  name                         = "firewall-avset"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  platform_update_domain_count = 2
  platform_fault_domain_count  = 2
  managed                      = true
}

resource "azurerm_lb" "external" {
  name                = "externalLB"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "externalLBPIP1"
    public_ip_address_id = "${azurerm_public_ip.fgvm01-pip.id}"
  }

  frontend_ip_configuration {
    name                 = "externalLBPIP2"
    public_ip_address_id = "${azurerm_public_ip.fgvm02-pip.id}"
  }
}

resource "azurerm_lb_probe" "external" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.external.id}"
  name                = "ssh-running-probe"
  protocol            = "Tcp"
  port                = 22
  interval_in_seconds = 5
}


# configure standard LB HA port rule. Note that HA port rule cannot be co-exist with NAT rule(s)

resource "azurerm_lb_backend_address_pool" "external" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.external.id}"
  name                = "externalLBBackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "fortivm01-nic02-external" {
  network_interface_id    = "${azurerm_network_interface.fortivm01-nic02.id}"
  ip_configuration_name   = "${join("", list("ipconfig", "1"))}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.external.id}"
  depends_on              = ["azurerm_virtual_network.frontend"]
}

resource "azurerm_network_interface_backend_address_pool_association" "fortivm02-nic02-external" {
  network_interface_id    = "${azurerm_network_interface.fortivm02-nic02.id}"
  ip_configuration_name   = "${join("", list("ipconfig", "1"))}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.external.id}"
  depends_on              = ["azurerm_virtual_network.frontend"]
}

resource "azurerm_lb_rule" "externalLB1" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.external.id}"
  name                           = "lbRule01"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "externalLBPIP1"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.external.id}"
  probe_id                       = "${azurerm_lb_probe.external.id}"
  depends_on                     = ["azurerm_lb_probe.external"]

  enable_floating_ip = true
}

resource "azurerm_lb_rule" "externalLB2" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.external.id}"
  name                           = "lbRule02"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "externalLBPIP2"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.external.id}"
  probe_id                       = "${azurerm_lb_probe.external.id}"
  depends_on                     = ["azurerm_lb_probe.external"]

  enable_floating_ip = true
}

/*
resource "azurerm_lb_nat_rule" "pubhttps01" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.external.id}"
  name                           = "pubhttps01"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "externalLBPIP1"
}

resource "azurerm_network_interface_nat_rule_association" "fgt01int2natrule01" {
  network_interface_id  = "${azurerm_network_interface.fortivm01-nic02.id}"
  ip_configuration_name = "${join("", list("ipconfig", "2"))}"
  nat_rule_id           = "${azurerm_lb_nat_rule.pubhttps01.id}"
}


resource "azurerm_lb_nat_rule" "pubhttps02" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.external.id}"
  name                           = "pubhttps02"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "externalLBPIP2"
}

resource "azurerm_network_interface_nat_rule_association" "fgt02int2natrule01" {
  network_interface_id  = "${azurerm_network_interface.fortivm02-nic02.id}"
  ip_configuration_name = "${join("", list("ipconfig", "2"))}"
  nat_rule_id           = "${azurerm_lb_nat_rule.pubhttps02.id}"
}


resource "azurerm_lb_nat_rule" "pubssh01" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.external.id}"
  name                           = "pubssh01"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "externalLBPIP1"
}

resource "azurerm_network_interface_nat_rule_association" "fgt01int2natrule02" {
  network_interface_id  = "${azurerm_network_interface.fortivm01-nic02.id}"
  ip_configuration_name = "${join("", list("ipconfig", "2"))}"
  nat_rule_id           = "${azurerm_lb_nat_rule.pubssh01.id}"
}


resource "azurerm_lb_nat_rule" "pubssh02" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.external.id}"
  name                           = "pubssh02"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "externalLBPIP2"
}
resource "azurerm_network_interface_nat_rule_association" "fgt02int2natrule02" {
  network_interface_id  = "${azurerm_network_interface.fortivm02-nic02.id}"
  ip_configuration_name = "${join("", list("ipconfig", "2"))}"
  nat_rule_id           = "${azurerm_lb_nat_rule.pubssh02.id}"
}
*/

resource "azurerm_lb" "internal" {
    name                = "internalLB"
    location           = "${var.location}"
    resource_group_name  =  "${azurerm_resource_group.resourcegroup.name}"
    sku = "Standard"
    
    frontend_ip_configuration {
        name                 = "internalLBfrontendIP"
        subnet_id = "${azurerm_subnet.internal.id}"
        private_ip_address = "10.20.2.10"
        private_ip_address_allocation = "Static"
    }
}

resource "azurerm_lb_backend_address_pool" "internal" {
    resource_group_name  =  "${azurerm_resource_group.resourcegroup.name}"
    loadbalancer_id     = "${azurerm_lb.internal.id}"
    name                = "internalLBBackEndAddressPool"
}

resource "azurerm_lb_probe" "internal" {
    resource_group_name  =  "${azurerm_resource_group.resourcegroup.name}"
    loadbalancer_id     = "${azurerm_lb.internal.id}"
    name                = "ssh-running-probe"
    protocol = "Tcp"
    port                = 22
    interval_in_seconds = 5
}

# configure standard LB HA port rule. Note that HA port rule cannot be co-exist with NAT rule(s)
resource "azurerm_lb_rule" "internal-rule-ha" {
    resource_group_name  =  "${azurerm_resource_group.resourcegroup.name}"
    loadbalancer_id                = "${azurerm_lb.internal.id}"
    name                           = "internal-rule-ha"
    protocol                       = "All"
    frontend_port                  = 0 
    backend_port                   = 0
    frontend_ip_configuration_name = "internalLBfrontendIP"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.internal.id}"
    probe_id = "${azurerm_lb_probe.internal.id}"
    depends_on = ["azurerm_lb_probe.internal"]
    
    enable_floating_ip = true
}

resource "azurerm_network_interface_backend_address_pool_association" "fortivm01-nic03-internal" {
  network_interface_id    = "${azurerm_network_interface.fortivm01-nic03.id}"
  ip_configuration_name   = "${join("", list("ipconfig", "2"))}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.internal.id}"
  depends_on              = ["azurerm_virtual_network.frontend"]
}

resource "azurerm_network_interface_backend_address_pool_association" "fortivm02-nic03-internal" {
  network_interface_id    = "${azurerm_network_interface.fortivm02-nic03.id}"
  ip_configuration_name   = "${join("", list("ipconfig", "2"))}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.internal.id}"
  depends_on              = ["azurerm_virtual_network.frontend"]
}

# route tables

resource "azurerm_route_table" "InternalToExternalLB" {
  name                = "front2internalLB"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "route-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.20.2.10"
  }

  route {
    name           = "ToFrontend"
    address_prefix = "10.20.1.0/24"
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "ToInternal"
    address_prefix = "10.20.2.0/24"
    next_hop_type  = "VnetLocal"
  }

  route {
    name                   = "ProtectedFrontend"
    address_prefix         = "10.20.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.20.2.10"
  }
}

resource "azurerm_route_table" "dmz01ToInternalLB" {
  name                = "back2internalLB"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "route-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.20.2.10"
  }

  route {
    name           = "ToFrontend"
    address_prefix = "10.20.1.0/24"
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "ToInternal"
    address_prefix = "10.20.2.0/24"
    next_hop_type  = "VnetLocal"
  }

  route {
    name                   = "ToVNet"
    address_prefix         = "10.20.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.20.2.10"
  }
}



resource "azurerm_subnet_route_table_association" "internal_route" {
  subnet_id      = "${azurerm_subnet.internal.id}"
  route_table_id = "${azurerm_route_table.InternalToExternalLB.id}"
}



resource "azurerm_subnet_route_table_association" "dmz01_route" {
  subnet_id      = "${azurerm_subnet.dmz01.id}"
  route_table_id = "${azurerm_route_table.dmz01ToInternalLB.id}"
}