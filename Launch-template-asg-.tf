# 1. The Launch Template (The Recipe)
resource "aws_launch_template" "app_lt" {
  name_prefix   = "java-app-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = "maryam"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.tomcat_sg.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.app_profile.name
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
# 1. Update and Install Java 17
dnf update -y
dnf install java-17-amazon-corretto-devel -y

# 2. Install Tomcat 9
cd /opt
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz
tar -xf apache-tomcat-9.0.75.tar.gz
mv apache-tomcat-9.0.75 tomcat
useradd -m tomcat
chown -R tomcat:tomcat /opt/tomcat

# 3. Setup Environment Variables
export GH_USER="${var.github_user}"
export GH_TOKEN="${var.github_token}"
export REPO="Java-App-using-3-tier-architecture"
export WAR_NAME="dptweb-1.0.war"

# 4. Download the .war file (Using the full, direct URL)
rm -rf /opt/tomcat/webapps/ROOT

# We use the direct URL so there are NO dollar signs ($) to confuse the server
curl -L -u "${var.github_user}:${var.github_token}" \
  -o "/opt/tomcat/webapps/ROOT.war" \
  "https://maven.pkg.github.com/Maryamcoco/Java-App-using-3-tier-architecture/com/devopsrealtime/dptweb/1.0/dptweb-1.0.war"

chown -R tomcat:tomcat /opt/tomcat/webapps/
chmod 644 /opt/tomcat/webapps/ROOT.war

# 5. Create the Systemd Service
cat <<SERVICE > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
# Spring Boot specific naming conventions
Environment="SPRING_DATASOURCE_URL=jdbc:mysql://${aws_db_instance.mysql.endpoint}/${var.db_name}?useSSL=false&allowPublicKeyRetrieval=true"
Environment="SPRING_DATASOURCE_USERNAME=${var.db_username}"
Environment="SPRING_DATASOURCE_PASSWORD=${var.db_password}"
# Keeping your original ones just in case
Environment="DB_URL=jdbc:mysql://${aws_db_instance.mysql.endpoint}/${var.db_name}"
Environment="DB_USER=${var.db_username}"
Environment="DB_PASS=${var.db_password}"

Environment=JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
User=tomcat
Group=tomcat
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

# 6. Start and Enable Tomcat
systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat

# 7. CloudWatch Agent
dnf install amazon-cloudwatch-agent -y
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

cat <<CWCONFIG > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": { "metrics_collection_interval": 60, "run_as_user": "root" },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/tomcat/logs/catalina.out",
            "log_group_name": "/aws/tomcat/application",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
CWCONFIG

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "JavaApp-Server"
    }
  }
}

# 2. Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                      = "WebServerASG"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  vpc_zone_identifier       = [aws_subnet.public[0].id, aws_subnet.public[1].id]
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 600

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "JavaApp-Server"
    propagate_at_launch = true
  }
}