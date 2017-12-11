resource "aws_eip" "mdsinfra_nat" {
  vpc = true
}

resource "aws_nat_gateway" "mdsinfra_nat_gw" {
  allocation_id = "${aws_eip.mdsinfra_nat.id}"
  subnet_id = "${aws_subnet.mdsinfra_public_subnet.id}"
  depends_on = ["aws_internet_gateway.mdsinfra_igw"]
  tags {
    Name    = "MDS Infra NAT Gateway"
    Project = "mdsinfra"
  }
}

// Create a route table allowing all addresses access to the IGW.
resource "aws_route_table" "mdsinfra_private_rt" {
  vpc_id = "${aws_vpc.mdsinfra_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.mdsinfra_nat_gw.id}"
  }

  tags {
    Name    = "MDS Infra Private Route Table using NAT"
    Project = "mdsinfra"
  }
}

// Associate Private Subnet with route tables to access internet.
resource "aws_route_table_association" "mdsinfra_private_app_subnet_rt" {
  subnet_id      = "${aws_subnet.mdsinfra_private_app_subnet.id}"
  route_table_id = "${aws_route_table.mdsinfra_private_rt.id}"
}

resource "aws_route_table_association" "mdsinfra_private_db_subnet_rt" {
  subnet_id      = "${aws_subnet.mdsinfra_private_db_subnet.id}"
  route_table_id = "${aws_route_table.mdsinfra_private_rt.id}"
}
