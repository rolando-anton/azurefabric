resource "azurerm_network_interface" "fortivm02-nic01" {
  name                = "fortivm02-nic01"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  depends_on          = ["azurerm_virtual_network.frontend"]

  ip_configuration {
    name                          = "${join("", list("ipconfig", "0"))}"
    subnet_id                     = "${azurerm_subnet.management.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.20.0.101"
    public_ip_address_id          = "${azurerm_public_ip.fgvm02-mgmt.id}"
  }

  enable_accelerated_networking = "true"
}

resource "azurerm_network_interface" "fortivm02-nic02" {
  name                = "fortivm02-nic02"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  depends_on          = ["azurerm_virtual_network.frontend"]

  ip_configuration {
    name                          = "${join("", list("ipconfig", "1"))}"
    subnet_id                     = "${azurerm_subnet.external.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.20.1.101"
  }

  depends_on = ["azurerm_virtual_network.frontend"]

  enable_ip_forwarding = "true"

  enable_accelerated_networking = "true"
}

resource "azurerm_network_interface" "fortivm02-nic03" {
  name                = "fortivm02-nic03"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  depends_on          = ["azurerm_virtual_network.frontend"]

  ip_configuration {
    name                          = "${join("", list("ipconfig", "2"))}"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.20.2.101"
  }

  enable_ip_forwarding = "true"

  enable_accelerated_networking = "true"
}

resource "azurerm_virtual_machine" "fgvm02" {
  name                = "FGVM02"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  vm_size             = "${var.fgtvmsize}"

  storage_os_disk {
    name              = "fgvm02-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "fortinet_fg-vm_payg"
    version   = "6.0.3"
  }

  # plan information required for marketplace images
  plan {
    name      = "fortinet_fg-vm_payg"
    product   = "fortinet_fortigate-vm_v5"
    publisher = "fortinet"
  }

  storage_data_disk {
    name              = "fgvm02-datasdisk"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "FGVM02"
    admin_username = "${var.adminUsername}"
    admin_password = "${var.adminPassword}"
  }

  availability_set_id = "${azurerm_availability_set.fgtAVSet.id}"

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_interface_ids        = ["${azurerm_network_interface.fortivm02-nic01.id}", "${azurerm_network_interface.fortivm02-nic02.id}", "${azurerm_network_interface.fortivm02-nic03.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fortivm02-nic01.id}"
}
