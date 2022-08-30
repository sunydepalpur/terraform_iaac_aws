module "networking" {
    source = "./modules/networking"
    secret_key           = "${var.secret_key}"
    access_key           = "${var.access_key}"
    region               = "${var.region}"
    environment          = "${var.environment}"
    vpc_cidr             = "${var.vpc_cidr}"
    public_subnets_cidr  = "${var.public_subnets_cidr}"
    private_subnets_cidr = "${var.private_subnets_cidr}"
    workload_subnets_cidr = "${var.workload_subnets_cidr}"
    availability_zones   = "${var.availability_zones}"
}

module "instance" {
    source = "./modules/instance"
    image_id = "${var.image_id}"
    workload_interface_id = module.networking.workload_interface_id
    private_interface_id = module.networking.private_interface_id
    depends_on = [module.networking]
}