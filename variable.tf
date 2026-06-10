variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "public_subnet1_cidr" {
  description = "Public Subnet 1 CIDR"
  type        = string
}

variable "public_subnet2_cidr" {
  description = "Public Subnet 2 CIDR"
  type        = string
}

variable "availability_zone1" {
  description = "Availability Zone 1"
  type        = string
}

variable "availability_zone2" {
  description = "Availability Zone 2"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
}

variable "bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}

