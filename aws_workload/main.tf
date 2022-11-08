resource "aws_subnet" "subnet" {
  vpc_id = var.vpc_id

  cidr_block        = var.subnet_cidr
  availability_zone = format("%s%s", var.aws_region, var.aws_az)

  tags = {
    Name = "${var.site_name}"
    Creator = var.owner_tag
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = var.route_table_id
}

resource "aws_instance" "workload" {
  ami                     = data.aws_ami.latest-fcos.id
  instance_type           = "t3.micro"
  user_data               = data.ct_config.workload.rendered
  vpc_security_group_ids  = [
    var.security_group_id,
  ]
  subnet_id               = aws_subnet.subnet.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 40
  }

  tags = {
    Name    = "${var.site_name}-wl"
    Creator = var.owner_tag
  }
}

output "site_name" {
  value = var.site_name
}
output "workload_public_ip" {
  value = aws_instance.workload.public_ip
}
output "workload_private_ip" {
  value = aws_instance.workload.private_ip
}
