terraform {
  backend "remote" {
    organization = "glich-stream"

    workspaces {
      name = "IaC-intro"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48"
    }
  }

  required_version = ">= 0.15.0"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

variable "sample_public_key" {
  description = "Sample environment public key value"
  type        = string
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "sample_key" {
  key_name   = "sample-key"
  public_key = var.sample_public_key

  tags = {
    "Name" = "sample_public_key"
  }
}

resource "aws_instance" "sample_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-0d2411db69a112a30"]
  key_name               = aws_key_pair.sample_key.key_name

  tags = {
    "Name" = "sample_server"
  }
}

output "sample_server_dns" {
  value = aws_instance.sample_server.public_dns
}
