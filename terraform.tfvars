//AWS 
region      = "us-east-1"
environment = "TestEnv"
image_id = "ami-052efd3df9dad4825"

/* module networking */
availability_zones   = ["us-east-1a"]
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24"] //List of public subnet cidr range
workload_subnets_cidr  = ["10.0.10.0/24"] //List of workload subnet cidr range
private_subnets_cidr = ["10.0.100.0/24"] //List of private subnet cidr range
