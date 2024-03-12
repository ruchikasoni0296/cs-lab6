variable "region" {
  default = "us-east-1"
}

variable "cidr_vpc" {
  default = "10.0.0.0/16"
}

variable "cidr_subnet" {
  default = "10.0.0.0/24"
}

variable "ami" {
  default = "ami-07761f3ae34c4478d"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "s3bucket_name" {
  default = "cs-lab6-s3-bucket"
}