
## Objectives

- Use terraform to create a AWS EC2 instance.
- Learn how to work with terraform CLI.

## Steps

## Prerequisites

- You have AWS CLI and configured with a valid security credentials.
- You have a key pair named `aws_login`. To create go to your AWS console and create a key pair named `aws_login`. After you've created the key pair, you'll have a file downloaded called `aws_login.pem`. We will use this file to SSH into our server later.

### Create Terraform Project

Create a directory for your Terraform project and create a Terraform configuration file (usually named `main.tf`) in that directory.

In this file, you define the AWS provider and the aws resources you want to create. In our case, we want to create an EC2 Instance. Here's a basic example:

```hcl
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
```

### Initialize Terraform

In your terminal, run the following command.

```bash
terraform init
```

This command initializes Terraform in the current working directory, downloads any necessary provider plugins.

### Dry Run

The `terraform plan` command in Terraform performs a dry run of your infrastructure code and shows you the expected changes to your infrastructure without actually making any modifications. 

```bash
terraform plan
```

### Apply the Configuration

Run the following command to create the AWS resources defined in your Terraform configuration:

```bash
terraform apply
```
Terraform will display a plan of the changes it's going to make. Review the plan and type "yes" when prompted to apply it.

### Verify Resources

After Terraform completes creating the resources defined in the configuration, you can verify the resources created in the AWS Management Console or by running the following command.

```
aws ec2 describe-instances
```

### Destroy Resources

If you want to remove the resources created by Terraform configuration, you can use the following command:

```
terraform destroy
```

### Accessing through SSH

We can run the following command to connect to the EC2 instance we've just created with Terraform. Replace `3.80.128.220` with the public IP of your instance.

```
ssh -i ./aws_login.pem ubuntu@3.80.128.220
```

This time you'll be able to connect to the remote VM.