terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  default = "ap-southeast-2"
}

variable "docker_image" {
  default = "kkrish123/campus-cyber-plan:latest"
}

data "aws_ami" "al2023_arm" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-arm64"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_security_group" "web" {
  name        = "campus-cyber-sg"
  description = "Allow HTTP only"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023_arm.id
  instance_type          = "t4g.micro"
  vpc_security_group_ids = [aws_security_group.web.id]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  user_data = <<-EOT
    #!/bin/bash
    dnf install -y docker
    systemctl enable --now docker
    docker run -d --restart always -p 80:8080 ${var.docker_image}
  EOT

  user_data_replace_on_change = true

  tags = {
    Name = "campus-cyber-plan"
  }
}

output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}
