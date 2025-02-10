# Configure AWS Provider
provider "aws" {
  region = "ap-south-1"  # Change region if needed
}

# Fetch latest Debian AMI automatically
data "aws_ami" "latest_debian" {
  most_recent = true
  owners      = ["136693071363"]  # Official Debian AMI owner

  filter {
    name   = "name"
    values = ["debian-*-amd64-*-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Security group allowing SSH and Flask app access
resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg"
  description = "Allow SSH and Flask app HTTP traffic"

  # Restrict SSH to YOUR public IP (Replace 43.204.112.21 with actual IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["43.204.112.21/32"]  # Allow SSH only from your machine
  }

  # Flask app port (5000) - Open for testing (Restrict in production)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all for testing (Restrict later)
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance (No custom VPC, uses default)
resource "aws_instance" "flask_app" {
  ami           = data.aws_ami.latest_debian.id  # Latest Debian AMI
  instance_type = "t2.micro"  # Free-tier eligible
  key_name      = "webserver1_key"  # AWS Key Pair name (Ensure it exists)

  # Attach security group
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  tags = {
    Name = "FlaskAppInstance"
  }
}

# Output public IP for SSH access
output "instance_ip" {
  value = aws_instance.flask_app.public_ip
}

