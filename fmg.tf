resource "azurerm_network_interface" "fmg-nic01" {
  name                = "fmg-nic01"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  depends_on          = ["azurerm_virtual_network.frontend"]

  ip_configuration {
    name                          = "${join("", list("ipconfig", "0"))}"
    subnet_id                     = "${azurerm_subnet.management.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.20.0.99"
    public_ip_address_id          = "${azurerm_public_ip.fmg-mgmt.id}"
  }

  depends_on = ["azurerm_virtual_network.frontend"]

}


resource "azurerm_virtual_machine" "fmg" {
  name                = "FMG"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  vm_size             = "${var.fgtvmsize}"

  storage_os_disk {
    name              = "fmg-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet-fortimanager"
    sku       = "fortinet-fortimanager"
    version   = "6.0.3"
  }

  # plan information required for marketplace images
  plan {
    name      = "fortinet-fortimanager"
    product   = "fortinet-fortimanager"
    publisher = "fortinet"
  }

    storage_data_disk {
        name          = "fmg-datasdisk"
        managed_disk_type       = "Standard_LRS"
        create_option = "Empty"
        lun = 0
        disk_size_gb = "30"
    }
  os_profile {
    computer_name  = "FMG"
    admin_username = "${var.adminUsername}"
    admin_password = "${var.adminPassword}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_interface_ids        = ["${azurerm_network_interface.fmg-nic01.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fmg-nic01.id}"
}
