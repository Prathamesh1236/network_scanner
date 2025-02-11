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

  # Restrict SSH to your public IP (Replace <YOUR_PUBLIC_IP>)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<YOUR_PUBLIC_IP>/32"]  # Restrict SSH only to your machine
  }

  # Flask app port (5000) - Allow only your IP (Change later for production)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["<YOUR_PUBLIC_IP>/32"]  # Restrict Flask access to your IP
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

  # Inject Jenkins SSH Public Key for passwordless SSH (for user 'admin')
  user_data = <<-EOF
    #!/bin/bash
    echo "Creating admin user and adding SSH key..."

    # Ensure 'admin' user exists
    if ! id "admin" &>/dev/null; then
      useradd -m -s /bin/bash admin
      echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    fi

    # Set up SSH key for 'admin'
    mkdir -p /home/admin/.ssh
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChNw9bGozFgbOQrvX1U9fGFK7cSgPZrP8pEhy08SYqY9SZUp86ViS+WeBVFMkFWz10JRmQSH2ztqc7NLM2gtuEeswXQJGXd4KRbDhYjeKp6yd5ZKz2e6skvnYEAPhmswgdBCp1uBecZW5rTlhwWMlWApHqKFCCvjDy/lG/LMsFR9QUhCSm5v5fpISLcQgxsYqTYH6X//V24pfOdGQtGviQMbcaWQKrNsP6HAzcnlwPYWPQp5isd2JhWvum/s7MjGqfcdwHD/gO0MaOlKZ2dFMc6XOclxx/w/dVV01fE3jN+eq4o4roQ1IH+AU/GnZIrMD4NKyqWYnqIZQ0DUpoNVENm8JqEJTcFB3DcyCTKuTh+Goy5K8Y7ndmuMsQTL74a47UCp8Aw5PUkE2cWnNWAxGoMuI1ngi/WbDSWY+udwHYtEx1vGX58sbkUm58ZxqLV1m+1We/8ngFtNrfr/tRcwV6l4nF+O8VGNjULjSQ7DpQYZYYB13CFH+4OOTAFqWUaSs= jenkins@ip-172-31-5-128" >> /home/admin/.ssh/authorized_keys

    chmod 700 /home/admin/.ssh
    chmod 600 /home/admin/.ssh/authorized_keys
    chown -R admin:admin /home/admin/.ssh

    echo "Setup complete!"
  EOF

  tags = {
    Name = "FlaskAppInstance"
  }
}

# Output public IP for SSH access
output "instance_ip" {
  value = aws_instance.flask_app.public_ip
}

