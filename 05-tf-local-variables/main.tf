provider "aws" {
  region = "us-east-1"
}

locals {
  sg_name        = "sg_vm1"
  sg_description = "security group for vm1 instance"

  # array of objects for ingress rules
  sg_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
  sg_egress_rule = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vm1_ami           = "ami-053b0d53c279acc90"
  vm1_instance_type = "t2.micro"
  vm1_key_name      = "aws_login"
  vm1_instance_name = "vm1"
  vm1_instance_tags = {
    Name        = local.vm1_instance_name
    Environment = "development"
  }
  vm1_user_data_script = <<-EOF
    #!/bin/bash
    apt-get -y update
    apt-get -y install nginx
    systemctl start nginx
    systemctl status nginx
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    sed -i "s/Welcome to nginx\!/$INSTANCE_ID/g" /var/www/html/*.html
  EOF
}

resource "aws_security_group" "sg_vm1" {
  name        = local.sg_name
  description = local.sg_description

  # dynamicly map ingress rule for each item in the array
  dynamic "ingress" {
    for_each = local.sg_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = local.sg_egress_rule.from_port
    to_port     = local.sg_egress_rule.to_port
    protocol    = local.sg_egress_rule.protocol
    cidr_blocks = local.sg_egress_rule.cidr_blocks
  }
}

resource "aws_instance" "vm1" {
  ami                    = local.vm1_ami
  instance_type          = local.vm1_instance_type
  key_name               = local.vm1_key_name
  vpc_security_group_ids = [aws_security_group.sg_vm1.id]
  tags                   = local.vm1_instance_tags
  user_data              = local.vm1_user_data_script
}
