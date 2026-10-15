terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}
provider "aws" { region = var.region }

variable "region" { default = "ap-south-1" }
variable "docker_image" { description = "e.g. youruser/campus-cyber-plan:latest" }
variable "my_ip_cidr" { description = "Your IP for SSH, e.g. 1.2.3.4/32" }
variable "key_name" { description = "Existing EC2 key pair name" }

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "web" {
  name        = "campus-cyber-sg"
  description = "Allow HTTP and restricted SSH"
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
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
  ami                    = data.aws_ssm_parameter.ami.value
  instance_type          = "t3.micro"
  key_name               = var.key_name
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
  tags = { Name = "campus-cyber-plan" }
}

output "website_url" { value = "http://${aws_instance.web.public_ip}" }
