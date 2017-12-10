/* Variable */
variable "provider" {
  type = "map"
  default = {
    access_key = "unknown"
    secret_key = "unknown"
    region     = "unknown"
  }
}

variable "vpc" {
  type    = "map"
  default = {
    "tag"         = "unknown"
    "cidr_block"  = "unknown"
    "subnet_bits" = "unknown"
    "owner_id"    = "unknown"
    "sns_topic"   = "unknown"
  }
}

variable "azs" {
  type = "map"
  default = {
    "ap-southeast-2" = "ap-southeast-2a,ap-southeast-2b,ap-southeast-2c"
    "eu-west-1"      = "eu-west-1a,eu-west-1b,eu-west-1c"
    "us-west-1"      = "us-west-1b,us-west-1c"
    "us-west-2"      = "us-west-2a,us-west-2b,us-west-2c"
    "us-east-1"      = "us-east-1c,us-west-1d,us-west-1e"
  }
}

variable "instance_type" {
  default = "t1.micro"
}

variable "key_name" {
  default = "unknown"
}

variable "nat" {
  type    = "map"
  default = {
    ami_image         = "unknown"
    instance_type     = "unknown"
    availability_zone = "unknown"
    key_name          = "unknown"
    filename          = "userdata_nat_asg.sh"
  }
}

/* Ubuntu Trusty 14.04 LTS (x64) */
variable "images" {
  type    = "map"
  default = {
    eu-west-1      = "ami-47a23a30"
    ap-southeast-2 = "ami-6c14310f"
    us-east-1      = "ami-2d39803a"
    us-west-1      = "ami-48db9d28"
    us-west-2      = "ami-d732f0b7"
  }
}

variable "env_domain" {
    type    = "map"
    default = {
        name    = "unknown"
        zone_id = "unknown"
    }
}