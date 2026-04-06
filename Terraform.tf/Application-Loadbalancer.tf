# 1. The Application Load Balancer (Public Facing)
resource "aws_lb" "main_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id # Placed in Public Subnets

  tags = { Name = "JavaApp-ALB" }
}

# 2. The Target Group (The "Waiting Room" for your EC2s)
resource "aws_lb_target_group" "app_tg" {
  name     = "java-app-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # Health Check: Ensures ALB only sends traffic to "healthy" Tomcat servers
  health_check {
    enabled             = true
    interval            = 30
    path                = "/" # Adjust if your app has a specific /health endpoint
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = { Name = "JavaApp-TargetGroup" }
}

# 3. The Listener (Listening for users on Port 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}