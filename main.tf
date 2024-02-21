terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# Upload pub key to AWS, allowing me to use the same key for SSH conns
resource "aws_key_pair" "test_server_key" {
  key_name   = "TestServerKey"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Get my public IP for the instance's SG
data "external" "my_public_ip" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

resource "aws_security_group" "allow_all_from_my_ip" {
  name        = "allow_all_from_my_ip"
  description = "Allow all traffic from my IP address"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = [format("%s/32", data.external.my_public_ip.result["ip"])]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "AllowAllFromMyIP"
  }
}
resource "aws_instance" "test_server_4" {
  ami                    = "ami-0de8a7e805b017a1f" # Ubuntu 22.04
  instance_type          = "t3.medium"             # Max allowable
  key_name               = aws_key_pair.test_server_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_all_from_my_ip.id]
  user_data              = file("${path.module}/startup.sh")

  root_block_device {
    volume_size = "50"
  }

  tags = {
    Name = "TestServer"
  }
}
