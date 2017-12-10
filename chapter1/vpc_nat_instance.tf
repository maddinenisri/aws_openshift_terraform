/*== NAT INSTANCE IAM PROFILE ==*/
resource "aws_iam_instance_profile" "nat" {
    name  = "${var.vpc["tag"]}-nat-profile"
    roles = ["${aws_iam_role.nat.name}"]
}

resource "aws_iam_role" "nat" {
    name = "${var.vpc["tag"]}-nat-role"
    path = "/"
    assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {"AWS": "*"},
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "nat" {
    name = "${var.vpc["tag"]}-nat-policy"
    path = "/"
    description = "NAT IAM policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:ModifyInstanceAttribute",
                "ec2:DescribeSubnets",
                "ec2:DescribeRouteTables",
                "ec2:CreateRoute",
                "ec2:ReplaceRoute"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "nat" {
    name       = "${var.vpc["tag"]}-nat-attachment"
    roles      = ["${aws_iam_role.nat.name}"]
    policy_arn = "${aws_iam_policy.nat.arn}"
}

/*=== NAT INSTANCE ASG ===*/
resource "aws_autoscaling_group" "nat" {
    name                      = "${var.vpc["tag"]}-nat-asg"
    availability_zones        = "${split(",", lookup(var.azs, var.provider["region"]))}"
    vpc_zone_identifier       = ["${aws_subnet.public-subnets.*.id}"]
    max_size                  = 1
    min_size                  = 1
    health_check_grace_period = 60
    default_cooldown          = 60
    health_check_type         = "EC2"
    desired_capacity          = 1
    force_delete              = true
    launch_configuration      = "${aws_launch_configuration.nat.name}"
    tag {
      key                 = "Name"
      value               = "NAT-${var.vpc["tag"]}"
      propagate_at_launch = true
    }
    tag {
      key                 = "Environment"
      value               = "${lower(var.vpc["tag"])}"
      propagate_at_launch = true
    }
    tag {
      key                 = "Type"
      value               = "nat"
      propagate_at_launch = true
    }
    tag {
      key                 = "Role"
      value               = "bastion"
      propagate_at_launch = true
    }
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_launch_configuration" "nat" {
    name_prefix                 = "${var.vpc["tag"]}-nat-lc-"
    image_id                    = "${lookup(var.images, var.provider["region"])}"
    instance_type               = "${var.nat["instance_type"]}"
    iam_instance_profile        = "${aws_iam_instance_profile.nat.name}"
    key_name                    = "${var.key_name}"
    security_groups             = ["${aws_security_group.nat.id}"]
    associate_public_ip_address = true
    user_data                   = "${data.template_file.nat.rendered}"
    lifecycle {
      create_before_destroy = true
    }
}

data "template_file" "nat" {
    template = "${file("${var.nat["filename"]}")}"
    vars {
        cidr = "${var.vpc["cidr_block"]}"
    }
}