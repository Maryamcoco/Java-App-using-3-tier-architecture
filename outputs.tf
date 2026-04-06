output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "The public URL of your application"
  value       = aws_lb.main_alb.dns_name
}