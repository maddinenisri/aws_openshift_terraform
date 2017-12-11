//Provider
provider "aws" {
  region = "${var.region}"
}

module "infrasetup" {
  source              = "./modules/infrasetup"
  region              = "${var.region}"
  amisize             = "t2.large"
  vpc_cidr            = "10.0.0.0/16"
  subnetaz            = "${var.subnetaz}"
  subnet_cidr         = "10.0.1.0/24"
  subnet_cidrs        = "${var.subnet_cidrs}"
  key_name            = "infrasetup"
  public_key_path     = "${var.public_key_path}"
}
