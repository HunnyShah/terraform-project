output "load_balancer_name" {
  description = "The name of the load balancer"
  value       = azurerm_lb.lb.name
}

output "load_balancer_public_ip" {
  description = "The public IP of the load balancer"
  value       = azurerm_public_ip.lb.ip_address
}