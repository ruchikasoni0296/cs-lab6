terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.39.1"
    }
  }
}

provider "aws" {
  region = var.region
}


resource "aws_iam_role" "my_role" {
  name               = "cs-lab6-role"
  assume_role_policy = jsonencode({
    Version          = "2012-10-17",
    Statement        = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "my_policy" {
  name        = "cs-lab6-policy"
  description = "Allow EC2 to access S3"
  policy      = jsonencode({
    Version     = "2012-10-17",
    Statement   = [
      {
        Action  = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = ["arn:aws:s3:::${var.s3bucket_name}", "arn:aws:s3:::${var.s3bucket_name}/*"]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "my_policy_attachment" {
  role       = aws_iam_role.my_role.name
  policy_arn = aws_iam_policy.my_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "cs-lab6-instance-profile"
  role = aws_iam_role.my_role.name
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.s3bucket_name
  tags = {
    Env = "cs-lab6"
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "cs-lab6-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.cidr_subnet
}

resource "aws_security_group" "my_security_group" {
  name        = "cs-lab6-security-group"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.my_vpc.id

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
}

resource "aws_instance" "my_instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.my_key.key_name
  subnet_id                   = aws_subnet.my_subnet.id
  security_groups             = [aws_security_group.my_security_group.id] 
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "my-EC2-instance"
  }
}
