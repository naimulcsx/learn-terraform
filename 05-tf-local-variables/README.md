## Objectives

- Learn about Terraform Local Variables
- Initialize a VM with NGINX that shows the Instance ID in the webpage.

## Prerequisites

- You have AWS CLI and configured with a valid security credentials.
- You have a key pair named `aws_login`. To create go to your AWS console and create a key pair named `aws_login`. After you've created the key pair, you'll have a file downloaded called `aws_login.pem`. We will use this file to SSH into our server later.

## Terraform Local Variables

Terraform local variables are variables that you define within a Terraform configuration to store intermediate values or simplify complex expressions. They are not exposed as outside inputs, but are used for internal use within the configuration. 

## Steps

Create a directory for your Terraform project and create a Terraform configuration file (usually named `main.tf`) in that directory.

In this file, you will define the AWS provider and the AWS resources you want to create. In our case, we want to create a security group and an EC2 Instance with user data.

### Define provider block

The provider is same as the previous example

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Locals block for the variables

We've defined all the variables in the locals block, and we'll use them when we define the resources.

```hcl
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
```

### Resource block for the security group

We'll refer to the values in the locals block using `local.VARIABLE_NAME`.


```hcl
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
```

### Resource block for the EC2 Instance

We'll refer to the values in the locals block using `local.VARIABLE_NAME`.

```hcl
resource "aws_instance" "vm1" {
  ami                    = local.vm1_ami
  instance_type          = local.vm1_instance_type
  key_name               = local.vm1_key_name
  vpc_security_group_ids = [aws_security_group.sg_vm1.id]
  tags                   = local.vm1_instance_tags
  user_data              = local.vm1_user_data_script
}
```

### Apply the Configuration

Run the following command to create the AWS resources defined in the Terraform configuration:

```bash
terraform apply
```

Terraform will display a plan of the changes it's going to make. Review the plan and type "yes" when prompted to apply it.

### Accessing through Web Browser

Try to visit the Public IP of the VM you created. You'll see NGINX's default page, but we'll see the instance id instead of "Welcome to NGINX". This means the user data ran successfully.

### Destroy Resources

If you want to remove the resources created by Terraform configuration, you can use the following command:

```
terraform destroy
```