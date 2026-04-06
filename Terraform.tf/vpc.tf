# 1. The VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Javaapp-VPC"
  }
}

# Internet Gateway (For Public Subnets)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "Main-IGW" }
}

# Public Subnets (For Load Balancer)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = count.index == 0 ? "10.0.1.0/24" : "10.0.2.0/24"
  availability_zone       = count.index == 0 ? "ap-northeast-1a" : "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = { Name = "Public-Subnet-${count.index + 1}" }
}

# 4. Private App Subnets (For Tomcat)
resource "aws_subnet" "app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = count.index == 0 ? "10.0.3.0/24" : "10.0.4.0/24"
  availability_zone = count.index == 0 ? "ap-northeast-1a" : "ap-northeast-1c"

  tags = { Name = "App-Subnet-${count.index + 1}" }
}

# 5. Private Data Subnets (For my RDS MySQL)
resource "aws_subnet" "db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = count.index == 0 ? "10.0.5.0/24" : "10.0.6.0/24"
  availability_zone = count.index == 0 ? "ap-northeast-1a" : "ap-northeast-1c"
  tags              = { Name = "DB-Subnet-${count.index + 1}" }
}

# 6. Public Route Table (Connects Public Subnets to Internet Gateway)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "Public-RT" }
}

# 7. Route Table Associations
resource "aws_route_table_association" "route_asso" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}