# Configure AWS Provider
provider "aws" {
  region = "us-east-1"  # Change region if needed
}

# Fetch latest Debian AMI
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

# Security group allowing SSH and Flask app traffic
resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg"
  description = "Allow SSH and Flask app HTTP traffic"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # WARNING: Restrict to your IP in production!
  }

  # Flask app port (default: 5000)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to public for demo purposes
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance with manual SSH key
resource "aws_instance" "flask_app" {
  ami           = data.aws_ami.latest_debian.id
  instance_type = "t2.micro"
  key_name      = "webserver1_key"  # MUST match your AWS key pair name!

  # Attach custom security group
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  tags = {
    Name = "FlaskAppInstance"
  }
}

# Output public IP for SSH access
output "instance_ip" {
  value = aws_instance.flask_app.public_ip
}
