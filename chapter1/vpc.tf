/*=== VPC AND SUBNETS ===*/
resource "aws_vpc" "environment" {
  cidr_block           = "${var.vpc["cidr_block"]}"
  enable_dns_support   = true
  enable_dns_hostnames = true 
  tags {
      Name        = "VPC-${var.vpc["tag"]}"
      Environment = "${lower(var.vpc["tag"])}"
  }
}

resource "aws_internet_gateway" "environment" {
    vpc_id = "${aws_vpc.environment.id}"
    tags {
        Name        = "${var.vpc["tag"]}-internet-gateway"
        Environment = "${lower(var.vpc["tag"])}"
    }
}

resource "aws_subnet" "public-subnets" {
    vpc_id            = "${aws_vpc.environment.id}"
    count             = "${length(split(",", lookup(var.azs, var.provider["region"])))}"
    cidr_block        = "${cidrsubnet(var.vpc["cidr_block"], var.vpc["subnet_bits"], count.index)}"
    availability_zone = "${element(split(",", lookup(var.azs, var.provider["region"])), count.index)}"
    tags {
        Name          = "${var.vpc["tag"]}-public-subnet-${count.index}"
        Environment   = "${lower(var.vpc["tag"])}"
    }
    map_public_ip_on_launch = true
}

resource "aws_subnet" "private-subnets" {
    vpc_id            = "${aws_vpc.environment.id}"
    count             = "${length(split(",", lookup(var.azs, var.provider["region"])))}"
    cidr_block        = "${cidrsubnet(var.vpc["cidr_block"], var.vpc["subnet_bits"], count.index + length(split(",", lookup(var.azs, var.provider["region"]))))}"
    availability_zone = "${element(split(",", lookup(var.azs, var.provider["region"])), count.index)}"
    tags {
        Name          = "${var.vpc["tag"]}-private-subnet-${count.index}"
        Environment   = "${lower(var.vpc["tag"])}"
        Network       = "private"
    }
}

resource "aws_subnet" "private-subnets-2" {
    vpc_id            = "${aws_vpc.environment.id}"
    count             = "${length(split(",", lookup(var.azs, var.provider["region"])))}"
    cidr_block        = "${cidrsubnet(var.vpc["cidr_block"], var.vpc["subnet_bits"], count.index + (2 * length(split(",", lookup(var.azs, var.provider["region"])))))}"
    availability_zone = "${element(split(",", lookup(var.azs, var.provider["region"])), count.index)}"
    tags {
        Name          = "${var.vpc["tag"]}-private-subnet-2-${count.index}"
        Environment   = "${lower(var.vpc["tag"])}"
        Network       = "private"
    }
}