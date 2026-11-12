
# ==========================================================
# DSO303 Assignment 2
# EC2 Launch Template and Auto Scaling Group
# Configuration only - do not apply yet
# ==========================================================

# Find the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Launch template for API instances
resource "aws_launch_template" "api" {
  name_prefix   = "dso303-api-"
  description   = "Launch template for Assignment 2 API"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.api.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.api.id]
    delete_on_termination       = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 16
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # Placeholder bootstrap: creates a health endpoint only.
  # The real API deployment will be added later.
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail

    mkdir -p /opt/dso303

    cat > /opt/dso303/health-server.py <<'PY'
    from http.server import BaseHTTPRequestHandler, HTTPServer

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == "/health":
                self.send_response(200)
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(b"healthy")
            else:
                self.send_response(404)
                self.end_headers()

    HTTPServer(("0.0.0.0", 80), Handler).serve_forever()
    PY

    cat > /etc/systemd/system/dso303-health.service <<'UNIT'
    [Unit]
    Description=DSO303 Placeholder Health Endpoint
    After=network.target

    [Service]
    Type=simple
    ExecStart=/usr/bin/python3 /opt/dso303/health-server.py
    Restart=always
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
    UNIT

    systemctl daemon-reload
    systemctl enable --now dso303-health.service
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "DSO303-API"
      Role = "Exam-API"
    }
  }

  tags = {
    Name = "DSO303-API-Launch-Template"
  }
}

# Auto Scaling Group spanning two Availability Zones
resource "aws_autoscaling_group" "api" {
  name_prefix = "dso303-api-asg-"

  vpc_zone_identifier = [
    aws_subnet.private_app_a.id,
    aws_subnet.private_app_b.id
  ]

  # Initial capacity is deliberately zero to avoid
  # launching EC2 instances if configuration is applied.
  min_size         = 0
  desired_capacity = 0
  max_size         = 2

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.api.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.api.arn
  ]

  tag {
    key                 = "Name"
    value               = "DSO303-API-AutoScaling"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "DSO303-Assignment2"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
