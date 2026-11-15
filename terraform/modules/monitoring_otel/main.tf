data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "otel" {
  name        = "${var.project_name}-${var.environment}-otel-collector-sg"
  description = "Security Group for OpenTelemetry Collector Gateway"
  vpc_id      = var.vpc_id

  ingress {
    description     = "OTLP gRPC receiver from App tier"
    from_port       = 4317
    to_port         = 4317
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  ingress {
    description     = "OTLP HTTP receiver from App tier"
    from_port       = 4318
    to_port         = 4318
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  ingress {
    description     = "OTel Collector Health check"
    from_port       = 13133
    to_port         = 13133
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    description = "Allow all outbound (NAT Gateway to OTLP backend, RDS/Redis scraping)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-otel-collector-sg"
    Environment = var.environment
  }
}

resource "aws_iam_role" "otel" {
  name = "${var.project_name}-${var.environment}-otel-collector-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-otel-collector-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.otel.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "otel" {
  name = "${var.project_name}-${var.environment}-otel-collector-profile"
  role = aws_iam_role.otel.name
}

resource "aws_launch_template" "otel" {
  name_prefix   = "${var.project_name}-${var.environment}-otel-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.otel.arn
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.otel.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl enable --now docker
    
    # Run OTel Collector Contrib container
    docker run -d --name otel-collector \
      --restart always \
      -p 4317:4317 \
      -p 4318:4318 \
      -p 13133:13133 \
      otel/opentelemetry-collector-contrib:latest
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-${var.environment}-otel-collector"
      Environment = var.environment
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "otel" {
  name_prefix         = "${var.project_name}-${var.environment}-otel-asg-"
  vpc_zone_identifier = var.subnet_ids

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.otel.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}
