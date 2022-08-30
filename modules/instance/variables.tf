// instance
variable "image_id" {
  type = string
  description = "AMI ID"
  default = "ami-08d70e59c07c61a3a"
}

variable "private_interface_id" {
    type = string
    description = "workload_interface_id"
}

variable "workload_interface_id" {
    type = string
    description = "workload_interface_id"
}