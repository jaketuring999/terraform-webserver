# Create ELB
resource "aws_elb" "web_elb" {
  name = "web-elb"
  availability_zones = var.availability_zones
  security_groups = [aws_security_group.elb_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  access_logs {
    bucket = aws_s3_bucket.elb_logs.bucket
    bucket_prefix = "web_elb_logs"
    interval = 60
  }

  health_check {
    healthy_threshold   = 2
    interval            = 30
    target              = "HTTP:80/"
    timeout             = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "web_elb"
  }
}

# Define launch configuration
resource "aws_launch_configuration" "web_config" {
  name_prefix   = "web_config"
  image_id      = var.ami #Ubuntu Server 22.04 LTS (Free tier eligible)
  instance_type = var.instance_type # t2.micro is within the AWS free tier
  security_groups = [aws_security_group.web_sg.id]
  # Key pair name
  key_name = var.key_pair_name
  lifecycle {
    create_before_destroy = true
  }

  # Script to install nginx and CloudWatch Logs agent and start the web server
  user_data = <<-EOF
              #!/bin/bash
              # Update the system
              sudo apt-get update -y
              # Install nginx
              sudo apt-get install -y nginx
              # Start nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx

              # Install CloudWatch Logs agent
              sudo apt-get install -y awscli
              sudo aws s3 cp s3://aws-codedeploy-us-east-1/latest/install . --region us-east-1
              sudo chmod +x ./install
              sudo ./install auto

              # Configure awslogs
              cat <<'CONFIG_BLOCK' > /etc/awslogs/awslogs.conf
              [general]
              state_file = /var/awslogs/state/agent-state

              [/var/log/nginx/access.log]
              file = /var/log/nginx/access.log
              log_group_name = /nginx/access.log
              log_stream_name = {instance_id}
              datetime_format = %d/%b/%Y:%H:%M:%S %z

              [/var/log/nginx/error.log]
              file = /var/log/nginx/error.log
              log_group_name = /nginx/error.log
              log_stream_name = {instance_id}
              datetime_format = %d/%b/%Y:%H:%M:%S %z
              CONFIG_BLOCK

              # Configure the AWS CLI with the region
              sudo aws configure set region us-east-1

              # Start the CloudWatch Logs agent
              sudo service awslogs start
              sudo systemctl enable awslogs
              EOF
    }
# Create autoscaling group
resource "aws_autoscaling_group" "web_asg" {
  launch_configuration = aws_launch_configuration.web_config.id
  vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  min_size = var.min_elb_capacity
  max_size = var.max_elb_capacity
  desired_capacity = var.desired_elb_capacity
  health_check_type = "ELB"
  health_check_grace_period = 300
  force_delete = true

  tag {
    key = "Name"
    value = "web_asg"
    propagate_at_launch = true
  }
}
