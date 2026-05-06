terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"  
  access_key = var.access_key
  secret_key = var.secret_key
}

# This data source automatically finds the correct AMI for us-east-1
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# create security group for the ec2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 22"

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Monitoring server security group"
  }
}

resource "aws_instance" "Monitoring_server" {
  ami             = data.aws_ami.ubuntu.id  # Automatically uses the us-east-1 ID
  instance_type   = "t2.medium"
  security_groups = [aws_security_group.ec2_security_group.name]
  key_name        = var.key_name

  tags = {
    Name = var.instance_name
  }
}
