//Region
variable "region" {
  description = "Default Cluster region"
  default = "us-east-1"
}

//SSH Key
variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

//For public subnet deployment
variable "subnetaz" {
  type = "map"

  default = {
    us-east-1 = "us-east-1a,us-east-1b,us-east-1c"
  }
}

variable "subnet_cidrs" {
  type = "list"

  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
