## Objectives

- Learn about Terraform Input Variables
- Initialize a VM with NGINX that shows the Instance ID in the webpage.

## Prerequisites

- You have AWS CLI and configured with a valid security credentials.
- You have a key pair named `aws_login`. To create go to your AWS console and create a key pair named `aws_login`. After you've created the key pair, you'll have a file downloaded called `aws_login.pem`. We will use this file to SSH into our server later.

## Local Variables vs Input Variables

In Terraform, local variables are internal to a configuration. On the other hand, input variables are outside inputs for modules, allowing users to customize the behavior of the module by providing the variables while we apply the configuration. This allows us to create highly configurable terraform configurations.

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

### Varible block for the input variables

We've defined all the variables in the locals block, and we'll use them when we define the resources. Here we'll create only 3 input variables to keep it short. When you are praticing, convert all the data into variables.

```hcl
# instance_name and instance_type will be prompted 
# for values when we run terraform apply command
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Type of the instance"
  type        = string
}

# terraform will not prompt for this, since it has a default value
variable "instance_ami" {
  description = "AMI of the EC2 instance"
  type        = string
  default     = "ami-053b0d53c279acc90"
}
```

### Resource block for the security group

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

We can refer to the values in the input variables using `var.VARIABLE_NAME`.

```hcl
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