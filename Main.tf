provider "azurerm" {

  version = "=2.20.0"
  features {}
}


#
#
###### Site 1 ~~North Europe~~#####
#
#
#



resource "azurerm_resource_group" "main" {
  name     = "Test-resources"
  location = "North Europe"
}

resource "azurerm_virtual_network" "main" {
  name                = "Test-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "Test-resources"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}




####  lb ###



resource "azurerm_public_ip" "main" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "main" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
 resource_group_name = azurerm_resource_group.main.name
 loadbalancer_id     = azurerm_lb.main.id
 name                = "BackEndAddressPool"
}

resource "azurerm_network_interface" "main" {
 count               = 2
 name                = "nic${count.index}"
 location            = azurerm_resource_group.main.location
 resource_group_name = azurerm_resource_group.main.name

 ip_configuration {
   name                          = "testConfiguration"
   subnet_id                     = azurerm_subnet.internal.id
   private_ip_address_allocation = "dynamic"
 }
}

resource "azurerm_availability_set" "avset" {
 name                         = "avset"
 location                     = azurerm_resource_group.main.location
 resource_group_name          = azurerm_resource_group.main.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 2
 managed                      = true
}

##VM 



resource "azurerm_virtual_machine" "main" {
 count                 = 2
 name                  = "Azure_vm${count.index}"
 location              = azurerm_resource_group.main.location
 availability_set_id   = azurerm_availability_set.avset.id
 resource_group_name   = azurerm_resource_group.main.name
 network_interface_ids = [element(azurerm_network_interface.main.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

}





#
#
###### Site 2 ~~East US~~#####
#
#
#



resource "azurerm_resource_group" "main2" {
  name     = "Test-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "main2" {
 name                = "VirtualNetwork"
 address_space       = ["10.0.0.0/16"]
 location            = azurerm_resource_group.main2.location
 resource_group_name = azurerm_resource_group.main2.name
}


resource "azurerm_subnet" "internal2" {
  name                 = "internal"
  resource_group_name = azurerm_resource_group.main2.name
  virtual_network_name = azurerm_virtual_network.main2.name
  address_prefixes     = ["10.0.2.0/24"]
}




####  lb ###



resource "azurerm_public_ip" "main2" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.main2.location
  resource_group_name = azurerm_resource_group.main2.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "main2" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.main2.location
  resource_group_name = azurerm_resource_group.main2.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main2.id
  }
}

resource "azurerm_lb_backend_address_pool" "main2" {
 resource_group_name = azurerm_resource_group.main2.name
 loadbalancer_id     = azurerm_lb.main.id
 name                = "BackEndAddressPool"
}

resource "azurerm_network_interface" "main2" {
 count               = 2
 name                = "nic${count.index}"
 location            = azurerm_resource_group.main2.location
 resource_group_name = azurerm_resource_group.main2.name

 ip_configuration {
   name                          = "testConfiguration"
   subnet_id                     = azurerm_subnet.internal2.id
   private_ip_address_allocation = "dynamic"
 }
}

resource "azurerm_availability_set" "avset2" {
 name                         = "avset"
 location                     = azurerm_resource_group.main2.location
 resource_group_name          = azurerm_resource_group.main2.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 2
 managed                      = true
}

##VM 



resource "azurerm_virtual_machine" "main2" {
 count                 = 2
 name                  = "Azure_vm${count.index}"
 location              = azurerm_resource_group.main2.location
 availability_set_id   = azurerm_availability_set.avset2.id
 resource_group_name   = azurerm_resource_group.main2.name
 network_interface_ids = [element(azurerm_network_interface.main2.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

}




### traffic_manager




resource "random_id" "server" {
  keepers = {
    azi_id = 1
  }

  byte_length = 8
}


resource "azurerm_traffic_manager_profile" "main" {
  name                = random_id.server.hex
  resource_group_name = azurerm_resource_group.main.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = random_id.server.hex
    ttl           = 100
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }


}


resource "azurerm_traffic_manager_endpoint" "main" {
  name                = random_id.server.hex
  resource_group_name = azurerm_resource_group.main.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  target              = "terraform.io"
  type                = "externalEndpoints"
  weight              = 100
}



