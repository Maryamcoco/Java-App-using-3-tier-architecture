resource "aws_cloudwatch_log_group" "tomcat_logs" {
  name              = "/aws/tomcat/application"
  retention_in_days = 1 # Keeps costs down for a portfolio project
}