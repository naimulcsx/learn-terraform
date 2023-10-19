## Objectives

- Learn about EC2 user data.
- Learn how to initialize a VM with NGINX server with terraform.

## Prerequisites

- You have AWS CLI and configured with a valid security credentials.
- You have a key pair named `aws_login`. To create go to your AWS console and create a key pair named `aws_login`. After you've created the key pair, you'll have a file downloaded called `aws_login.pem`. We will use this file to SSH into our server later.

## EC2 User Data

EC2 User Data allows you to provide scripts or configuration data to EC2 instances during their launch. This data is executed on the instance, enabling automation of tasks like software installation, system configuration, and more

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

### Resource block for the security group

In the security group, we need to add a new ingress rule to allow inbound traffic through port 80, because our NGINX server will run on port 80.

```hcl
resource "aws_security_group" "sg_vm1" {
  name        = "sg_vm1"
  description = "sg for vm1 to allow SSH and HTTP traffic"
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
```

### Resource block for the EC2 Instance

It's almost same as previous excercise. The difference is that we've a new property called `user_data` defined.

```hcl
resource "aws_instance" "vm1" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = "aws_login"
  vpc_security_group_ids = [aws_security_group.sg_vm1.id]
  tags = {
    Name        = "vm1"
    Environment = "development"
  }
  user_data = <<EOF
#!/bin/bash
apt-get -y update
apt-get -y install nginx
systemctl start nginx
systemctl status nginx

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

Try to visit the Public IP of the VM you created. You'll see NGINX's default page, that means our user data successfully installed NGINX through EC2 user data.


### Destroy Resources

If you want to remove the resources created by Terraform configuration, you can use the following command:

```
terraform destroy
```