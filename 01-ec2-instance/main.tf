provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my-app" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name      = "aws_login"
  tags = {
    Name        = "ec2_vm1"
    Environment = "development"
  }
}
