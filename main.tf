provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "portfolio_rg" {
  name     = "portfolioResourceGroup"
  location = "West Europe"
}

# Create a virtual network
resource "azurerm_virtual_network" "portfolio_vnet" {
  name                = "portfolioVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.portfolio_rg.location
  resource_group_name = azurerm_resource_group.portfolio_rg.name
}

# Create a subnet
resource "azurerm_subnet" "portfolio_subnet" {
  name                 = "portfolioSubnet"
  resource_group_name  = azurerm_resource_group.portfolio_rg.name
  virtual_network_name = azurerm_virtual_network.portfolio_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a network security group
resource "azurerm_network_security_group" "portfolio_nsg" {
  name                = "portfolioNSG"
  location            = azurerm_resource_group.portfolio_rg.location
  resource_group_name = azurerm_resource_group.portfolio_rg.name
}

# Create a security rule
resource "azurerm_network_security_rule" "portfolio_nsg_rule" {
  name                        = "HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.portfolio_rg.name
  network_security_group_name = azurerm_network_security_group.portfolio_nsg.name
}

# Associate subnet with network security group
resource "azurerm_subnet_network_security_group_association" "portfolio_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.portfolio_subnet.id
  network_security_group_id = azurerm_network_security_group.portfolio_nsg.id
}

# Create an App Service Plan
resource "azurerm_service_plan" "portfolio_asp" {
  name                = "portfolioAppServicePlan"
  location            = azurerm_resource_group.portfolio_rg.location
  resource_group_name = azurerm_resource_group.portfolio_rg.name

  os_type   = "Linux"   # Change to "Windows" if required
  sku_name  = "B1"      # Choose the appropriate SKU
}

# Create an App Service
resource "azurerm_app_service" "portfolio_app" {
  name                = "portfolioAppService"
  location            = azurerm_resource_group.portfolio_rg.location
  resource_group_name = azurerm_resource_group.portfolio_rg.name
  app_service_plan_id = azurerm_service_plan.portfolio_asp.id

  site_config {
    dotnet_framework_version = "v4.0" # Update as needed or remove for non-.NET apps
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }
}
