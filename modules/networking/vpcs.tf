/*==== The VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}
/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-igw"
    Environment = "${var.environment}"
  }
}
/* Elastic IP for NAT */
resource "aws_eip" "workload_nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

resource "aws_eip" "private_nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}
/* NAT */
resource "aws_nat_gateway" "workload_nat" {
  allocation_id = "${aws_eip.workload_nat_eip.id}"
  subnet_id     = "${element(aws_subnet.workload_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "workload_nat"
    Environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "private_nat" {
  allocation_id = "${aws_eip.private_nat_eip.id}"
  subnet_id     = "${element(aws_subnet.private_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "private_nat"
    Environment = "${var.environment}"
  }
}
/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${element(var.public_subnets_cidr,   count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-      public-subnet"
    Environment = "${var.environment}"
  }
}
/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.private_subnets_cidr)}"
  cidr_block              = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
    Environment = "${var.environment}"
  }
}

/* Workload subnet */
resource "aws_subnet" "workload_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.workload_subnets_cidr)}"
  cidr_block              = "${element(var.workload_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-workload-subnet"
    Environment = "${var.environment}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}

/* Routing table for workload subnet */
resource "aws_route_table" "workload" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-workload-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.private_nat.id}"
}

resource "aws_route" "workload_nat_gateway" {
  route_table_id         = "${aws_route_table.workload.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.workload_nat.id}"
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "workload" {
  count          = "${length(var.workload_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.workload_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.workload.id}"
}
/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "workload-sg" {
  name        = "${var.environment}-workload-sg"
  description = "Allow workload inbound traffic"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]

  ingress {
    description      = "SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = "${var.public_subnets_cidr}"
  }


  tags = {
    Name = "workload-sg"
  }
}

resource "aws_security_group" "private-sg" {
  name        = "${var.environment}-private-sg"
  description = "Allow private inbound traffic"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]

  ingress {
    description      = "SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = "${var.workload_subnets_cidr}"
  }

  tags = {
    Name = "private-sg"
  }
}

resource "aws_network_interface" "private_interface" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id   = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  private_ips = ["10.0.100.100"]

  tags = {
    Name = "private_network_interface"
  }
}

resource "aws_network_interface" "workload_interface" {
  count          = "${length(var.workload_subnets_cidr)}"
  subnet_id   = "${element(aws_subnet.workload_subnet.*.id, count.index)}"
  private_ips = ["10.0.10.100"]

  tags = {
    Name = "workload_network_interface"
  }
}

resource "aws_network_interface_sg_attachment" "private_sg_attachment" {
  security_group_id    = aws_security_group.private-sg.id
  network_interface_id = aws_network_interface.private_interface.0.id
}

resource "aws_network_interface_sg_attachment" "workload_sg_attachment" {
  security_group_id    = aws_security_group.workload-sg.id
  network_interface_id = aws_network_interface.workload_interface.0.id
}