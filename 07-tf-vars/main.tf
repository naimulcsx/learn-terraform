provider "aws" {
  region = "us-east-1"
}

# instance_name and instance_type will be prompted for values
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}
variable "instance_type" {
  description = "Type of the instance"
  type        = string
}

# terraform will not prompt for this, since it has default value
variable "instance_ami" {
  description = "AMI of the EC2 instance"
  type        = string
  default     = "ami-053b0d53c279acc90"
}

resource "aws_security_group" "sg_vm1" {
  name        = "sg_vm1"
  description = "security group for vm1 instance"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vm1" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = "aws_login"
  vpc_security_group_ids = [aws_security_group.sg_vm1.id]
  tags = {
    Name        = var.instance_name
    Environment = "development"
  }
  user_data = <<EOF
#!/bin/bash
apt-get -y update
apt-get -y install nginx
systemctl start nginx
systemctl status nginx
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
sed -i "s/Welcome to nginx\!/$INSTANCE_ID/g" /var/www/html/*.html
EOF
}
