provider "aws" {
  region = "us-east-1"
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

resource "aws_instance" "my-app" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = "aws_login"
  vpc_security_group_ids = [aws_security_group.sg_vm1.id]
  tags = {
    Name        = "ec2_vm1"
    Environment = "development"
  }
}
