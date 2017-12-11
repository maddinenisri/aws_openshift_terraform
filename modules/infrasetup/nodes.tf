// Create an SSH keypair
resource "aws_key_pair" "mdsinfra_keypair" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "mdsinfra_sample_ec2" {
  ami = "${data.aws_ami.amazonlinux.id}"
  instance_type = "t2.micro"
  security_groups = [
    "${aws_security_group.mdsinfra_public_ingress.id}", 
    "${aws_security_group.mdsinfra_public_egress.id}", 
    "${aws_security_group.mdsinfra_public_ssh.id}"
  ]
  subnet_id = "${aws_subnet.mdsinfra_public_subnet.id}"
  key_name = "${aws_key_pair.mdsinfra_keypair.key_name}"
  user_data = <<-EOF
  #!/bin/bash
  sudo yum update –y
  sudo yum install -y httpd24
  sudo service httpd start
  sudo chkconfig httpd on
  EOF

  tags {
    Name = "Sample EC2 Instance in Public Subnet"
    Project = "mdsinfra"
  }
}
