#Grupo de recursos principal
resource "azurerm_resource_group" "grupo5" {
	name 				= var.name
	location 		= var.location
	tags 				= {
		diplomado = "diplomado-grupo5-rg"
	}
}

resource "azurerm_container_registry" "acr" {
	name 									= "acrgrupo5"
	resource_group_name 	= azurerm_resource_group.grupo5.name	
	location 							= azurerm_resource_group.grupo5.location
	sku 									= "basic"
	admin_enabled 				= true
	tags 				= {
		diplomado = "diplomado-grupo5-acr"
	}
}

#Network
resource "azurerm_virtual_network" "virtualnetwork" {
	name 									= "virtualnetworkgrupo5"
	address_space 				= ["25.0.0.0/16"]
	resource_group_name 	= azurerm_resource_group.grupo5.name	
	location 							= azurerm_resource_group.grupo5.location
	tags 				= {
		diplomado = "diplomado-grupo5-virtualnetwork"
	}
}

resource "azurerm_subnet" "subnet" {
	name 										= "subnetinterna"
	address_prefixes 				= ["25.0.0.0/20"]
	resource_group_name 		= azurerm_resource_group.grupo5.name
	virtual_network_name 		= azurerm_virtual_network.virtualnetwork.name
}

#Crear interfaz de red para master
resource "azurerm_network_interface" "networkinterfacemaster" {
  name = "networkinterfacegrupo5-master"
  location  = azurerm_resource_group.grupo5.location
  resource_group_name = azurerm_resource_group.grupo5.name
  ip_configuration {
    name = "interna"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
	tags	= {
		diplomado = "diplomado-grupo5-networkinterface"
	}
}

#Crear interfaz de red para nodo
resource "azurerm_network_interface" "networkinterfacenodo" {
  name = "networkinterfacegrupo5-nodo"
  location  = azurerm_resource_group.grupo5.location
  resource_group_name = azurerm_resource_group.grupo5.name
  ip_configuration {
    name = "interna"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
	tags	= {
		diplomado = "diplomado-grupo5-networkinterface"
	}
}

#Crear una máquina virtual para master
resource "azurerm_linux_virtual_machine" "virtualmachinemaster" {
  name = "virtualmachinegrupo5-master"
  location = azurerm_resource_group.grupo5.location
  resource_group_name = azurerm_resource_group.grupo5.name
  size = "Standard_B1ls"
  network_interface_ids = [azurerm_network_interface.networkinterfacemaster.id]
  admin_username = var.uservm
  admin_password = var.passvm
  disable_password_authentication = false
  computer_name = "hostname"
  #no es storage, es source
  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version = "latest"
  }
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
	tags	= {
		diplomado = "diplomado-grupo5-virtualmachine"
	}
}

#Ejecutar script luego de creada la VM
#VM Master
#Sin probar aún
resource "azurerm_virtual_machine_extension" "virtualmachinemaster" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.virtualmachinemaster.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "apt-add-repository -y ppa:ansible/ansible && apt-get update -y && apt-get install -y ansible"
    }
SETTINGS

  tags = {
		diplomado = "diplomado-grupo5-virtualmachine"
  }

}

# Crear máquina virtual para nodo
resource "azurerm_linux_virtual_machine" "virtualmachinenodo" {
  name = "virtualmachinegrupo5-nodo"
  location = azurerm_resource_group.grupo5.location
  resource_group_name = azurerm_resource_group.grupo5.name
  size = "Standard_B1ls"
  network_interface_ids = [azurerm_network_interface.networkinterfacenodo.id]
  admin_username = var.uservm
  admin_password = var.passvm
  disable_password_authentication = false
  computer_name = "hostname"
  #no es storage, es source
  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version = "latest"
  }
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
	tags	= {
		diplomado = "diplomado-grupo5-virtualmachine"
	}
}

#Cluster Kubernetes
resource "azurerm_kubernetes_cluster" "grupo5clusteraks" {
	name 									= "aksdiplomadogrupo5"
	resource_group_name 	= azurerm_resource_group.grupo5.name	
	location 							= azurerm_resource_group.grupo5.location
	dns_prefix 						= "aks"
	kubernetes_version 		= "1.19.6"

	 default_node_pool {
		 name 								= "default"
		 node_count 					= 1
		 vm_size 							= "Standard_D2_V2"
		 vnet_subnet_id 			= azurerm_subnet.subnet.id
		 enable_auto_scaling 	= true
		 max_count 						= 3
		 min_count						= 1
	 }

	 network_profile {
		 network_plugin = "azure"
		 network_policy = "azure"
	 }

	 role_based_access_control {
		 enabled = true
	 }
	
	service_principal {
		client_id						= var.clientID
		client_secret      	= var.secret
	}

}

# Nodos extras de Kubernetes. Debieran ser 80 pero hay límite hasta 4
/*
resource "azurerm_kubernetes_cluster_node_pool" "grupo5clusteraks" {
	name 									= "internal"
	kubernetes_cluster_id	= azurerm_kubernetes_cluster.grupo5clusteraks.id
	vm_size								= "Standard_DS2_v2"
	node_count						= 2

	tags = {
		diplomado = "tagdiplomado-grupo5"
	}

}
*/
