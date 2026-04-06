#DB Subnet Group (I'm telling RDS which private subnets to live in)
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id

  tags = { Name = "My-DB-Subnet-Group" }
}

#RDS MySQL Instance
resource "aws_db_instance" "mysql" {
  allocated_storage = var.db_storage
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.db_instance_class
  db_name           = var.db_name
  username          = var.db_username
  password          = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false
  
  tags = { Name = "JavaApp-Database" }
}