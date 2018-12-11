resource "azurerm_network_interface" "webserver01-nic" {
    name                = "webserver01-nic"
    location            = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
    depends_on          = ["azurerm_virtual_network.dmz01"]
    ip_configuration {
        name = "${join("", list("ipconfig", "0"))}"
        subnet_id = "${azurerm_subnet.dmz01.id}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.30.1.200" 
    }
}

resource "azurerm_virtual_machine" "webserver01" {
    name                  = "webserver01"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  vm_size               = "${var.vmsize}"

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    storage_os_disk {
        name          = "webserver01-osdisk"
        caching       = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }


    os_profile {
        computer_name  = "webserver01"
        admin_username = "${var.adminUsername}"
        admin_password = "${var.adminPassword}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
    network_interface_ids = ["${azurerm_network_interface.webserver01-nic.id}"]


}
