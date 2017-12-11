// Create custom VPC
resource "aws_vpc" "mdsinfra_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
    Name    = "MDS Custom VPN"
    Project = "mdsinfra"
  }
}

// Create an Internet Gateway for the VPC.
resource "aws_internet_gateway" "mdsinfra_igw" {
  vpc_id = "${aws_vpc.mdsinfra_vpc.id}"

  tags {
    Name    = "MDS Custom IGW"
    Project = "mdsinfra"
  }
}

// Create a public subnet.
resource "aws_subnet" "mdsinfra_public_subnet" {
  vpc_id                  = "${aws_vpc.mdsinfra_vpc.id}"
  cidr_block              = "${element(var.subnet_cidrs, 0)}"
  availability_zone       = "${element(split(",", lookup(var.subnetaz, var.region)), 0)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.mdsinfra_igw"]

  tags {
    Name    = "MDS Public Subnet"
    Project = "mdsinfra"
  }
}

// Create a private subnet.
resource "aws_subnet" "mdsinfra_private_app_subnet" {
  vpc_id                  = "${aws_vpc.mdsinfra_vpc.id}"
  cidr_block              = "${element(var.subnet_cidrs, 1)}"
  availability_zone       = "${element(split(",", lookup(var.subnetaz, var.region)), 1)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.mdsinfra_igw"]

  tags {
    Name    = "MDS Private APP Subnet"
    Project = "mdsinfra"
    Network = "app"
  }
}

// Create a private subnet.
resource "aws_subnet" "mdsinfra_private_db_subnet" {
  vpc_id                  = "${aws_vpc.mdsinfra_vpc.id}"
  cidr_block              = "${element(var.subnet_cidrs, 2)}"
  availability_zone       = "${element(split(",", lookup(var.subnetaz, var.region)), 2)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.mdsinfra_igw"]

  tags {
    Name    = "MDS Private DB Subnet"
    Project = "mdsinfra"
    Network = "db"
  }
}

// Create a route table allowing all addresses access to the IGW.
resource "aws_route_table" "mdsinfra_public_rt" {
  vpc_id = "${aws_vpc.mdsinfra_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.mdsinfra_igw.id}"
  }

  tags {
    Name    = "MDS Infra Public Route Table"
    Project = "mdsinfra"
  }
}

// Associate Public Subnet with route tables to access from internet.
resource "aws_route_table_association" "mdsinfra_public_subnet_rt" {
  subnet_id      = "${aws_subnet.mdsinfra_public_subnet.id}"
  route_table_id = "${aws_route_table.mdsinfra_public_rt.id}"
}
