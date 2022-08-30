resource "aws_instance" "private_app_server" {
  ami           = "${var.image_id}"
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = "${var.private_interface_id}"
    device_index         = 0
  }
  # sg  < wkl
  tags = {
    Name = "PrivateAppServerInstance"
  }
}

resource "aws_instance" "workload_app_server" {
  ami           = "${var.image_id}"
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = "${var.workload_interface_id}"
    device_index         = 0
  }
  # sg < pb
  tags = {
    Name = "WorkloadAppServerInstance"
  }
}