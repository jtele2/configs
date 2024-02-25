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
resource "aws_key_pair" "practice_server_key" {
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

resource "aws_instance" "practice_server_1" {
  ami                    = "ami-0de8a7e805b017a1f" # Ubuntu 22.04
  instance_type          = "t3.medium"             # Max allowable
  key_name               = aws_key_pair.practice_server_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_all_from_my_ip.id]
  user_data              = file("${path.module}/startup.sh")
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = "50"
  }

  tags = {
    Name = "practiceServer"
  }
}

# Create IAM Role for the instance
resource "aws_iam_role" "ec2_role" {
  name = "ec2Role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the pre-made ACG policies to the Role
resource "aws_iam_role_policy_attachment" "ec2_policy_attach_allow_all" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::440679360547:policy/allow_all"
}
resource "aws_iam_role_policy_attachment" "ec2_policy_attach_playground" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::440679360547:policy/Playground_AWS_Sandbox"
}

# Create Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2Profile"
  role = aws_iam_role.ec2_role.name
}
