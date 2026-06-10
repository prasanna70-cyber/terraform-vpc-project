output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main_vpc.id
}

output "webserver1_public_ip" {
  description = "Web Server 1 Public IP"
  value       = aws_instance.webserver1.public_ip
}

output "webserver2_public_ip" {
  description = "Web Server 2 Public IP"
  value       = aws_instance.webserver2.public_ip
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS Name"
  value       = aws_lb.alb.dns_name
}
