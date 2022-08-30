variable "access_key" {
  type = string
  description = "AWS Console access Key"
}

variable "secret_key" {
  type = string
  description = "AWS Console secret Key"
}

variable "region" {
    type = string
    default = "us-east-1"
    description = "AWS Region"
}

variable "environment" {
  type = string
  description = "ENV"
}

//Networking
variable "availability_zones" {
  type    = list(string)
  default = ["us-west-1a"]
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
}

variable "workload_subnets_cidr" {
  type        = list
  description = "The CIDR block for the workload subnet"
}