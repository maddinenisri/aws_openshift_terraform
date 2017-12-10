vpc = {
  tag                   = "openshift_install"
  cidr_block            = "10.99.0.0/20"
  subnet_bits           = "4"
}
key_name                  = "mds_installer"
nat.instance_type         = "m3.medium"
env_domain = {
  name                  = "mdstechinc.com"
}