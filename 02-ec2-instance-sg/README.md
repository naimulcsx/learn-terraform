## Objectives

- Investigate why we couldn't SSH into our VM in the previous exercise.
- Learn about Security Groups (SG) and how to create and assign security groups to a VM.

## Prerequisites

- You have AWS CLI and configured with a valid security credentials.
- You have a key pair named `aws_login`. To create go to your AWS console and create a key pair named `aws_login`. After you've created the key pair, you'll have a file downloaded called `aws_login.pem`. We will use this file to SSH into our server later.

## Security Groups

In AWS, Security Groups are virtual firewalls that control inbound and outbound traffic to and from Amazon EC2 instances. Now let's see why we couldn't SSH into our VM in the previous exercise.

In our previous VM, we didn't mention any security group while creating the EC2 Instance, so AWS attached the default security group which doesn't allow any inbound traffic to the VM. That means in order to SSH into our VMs, either we have to update the default security group to allow traffic from 22 port or we have to create a brand new security group, that allows inbound traffic to port 22.

## Steps

### Create Terraform Project

Create a directory for your Terraform project and create a Terraform configuration file (usually named `main.tf`) in that directory.

In this file, you will define the AWS provider and the AWS resources you want to create. In our case, we want to create a security group and an EC2 Instance attached to that security group. Here's a basic example:

```hcl
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vm1" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = "aws_login"
  vpc_security_group_ids = [aws_security_group.sg_vm1.id]
  tags = {
    Name        = "vm1"
    Environment = "development"
  }
}
```

### Apply the Configuration

Run the following command to create the AWS resources defined in the Terraform configuration:

```bash
terraform apply
```
Terraform will display a plan of the changes it's going to make. Review the plan and type "yes" when prompted to apply it.

### Accessing through SSH

We can run the following command to connect to the EC2 instance we've just created with Terraform. Replace `3.80.128.220` with the public IP of your instance.

```
ssh -i ./aws_login.pem ubuntu@3.80.128.220
```

Can you connect? No? You can try to connect with the EC2 Instance Connect from AWS Console. But it will not work either. What's the issue here? We'll find this out in the next exercise.


### Destroy Resources

If you want to remove the resources created by Terraform configuration, you can use the following command:

```
terraform destroy
```