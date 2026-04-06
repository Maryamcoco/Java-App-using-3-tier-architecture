variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "javaappdb"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
  default     = "secure_password"
}

variable "db_instance_class" {
  description = "The type of instance to use for the database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_storage" {
  description = "The allocated storage in GB for the database"
  type        = number
  default     = 16
}

variable "ami_id" {
  description = "The AMI ID for the instances"
  type        = string
  default     = "ami-05284d16d6b516ace"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

variable "app_port" {
  description = "The port Tomcat is listening on"
  type        = number
  default     = 8080
}

variable "alb_name" {
  description = "The name of the Load Balancer"
  type        = string
  default     = "java-app-alb"
}

variable "github_user" {
  description = "GitHub username"
  type        = string
  default     = "Username"
}

variable "github_token" {
  description = "GitHub Personal Access Token (PAT)"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "Java-App-using-3-tier-architecture"
}

variable "war_file_name" {
  description = "The name of .war file"
  type        = string
  default     = "dptweb-1.0.war"
}