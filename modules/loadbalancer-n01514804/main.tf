# Create the Public IP Prefix (range of IPs)
resource "azurerm_public_ip_prefix" "example" {
  name                = "${var.prefix}-ip-prefix"
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix_length       = 28  
  sku                  = "Standard"  
}

# Create the Load Balancer Public IP from the Prefix
resource "azurerm_public_ip" "lb" {
  name                      = "${var.prefix}-PIP-LB"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  allocation_method         = "Static"
  public_ip_prefix_id       = azurerm_public_ip_prefix.example.id  
  sku                       = "Standard" 
  tags = var.tags
}

# Create the Load Balancer
resource "azurerm_lb" "lb" {
  name                = "${var.prefix}-LB"
  resource_group_name = var.resource_group_name
  location            = var.location

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.lb.id  
  }
}

# Backend Pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "backend-pool"
}

# Backend Pool association for Linux VMs
resource "azurerm_network_interface_backend_address_pool_association" "linux" {
  count = length(var.linux_nic_ids)

  network_interface_id    = var.linux_nic_ids[count.index]
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
  ip_configuration_name   = "ipconfig1"
}

# Load Balancer Probe
resource "azurerm_lb_probe" "probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "health-probe"
  port                = 80
  protocol            = "Http"
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load Balancer Rule (HTTP)
resource "azurerm_lb_rule" "rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip-config"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.probe.id
}
