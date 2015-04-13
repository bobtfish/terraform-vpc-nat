module "vpc" {
    source = "github.com/bobtfish/terraform-vpc"
    region = "${var.region}"
    account = "${var.account}"
    networkprefix = "${var.networkprefix}"
}

resource "aws_route_table" "private" {
    vpc_id = "${module.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${element(split(\",\", module.instances.instance_ids), 0)}" /* FIXME */
    }

    tags {
        Name = "${var.region} ${var.account} private"
    }
}

resource "aws_main_route_table_association" "private" {
    vpc_id = "${module.vpc.id}"
    route_table_id = "${aws_route_table.private.id}"
}

resource "aws_security_group" "allow_all" {
  name = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id = "${module.vpc.id}"

  ingress {
      from_port = 0
      to_port = 65535
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

module "instances" {
  source = "github.com/terraform-community-modules/tf_aws_nat"
  instance_type = "${var.instance_type}"
  region = "${var.region}"
  instance_count = "2"
  aws_key_name = "${var.aws_key_name}"
  subnet_ids = "${element(split(\",\", module.vpc.frontsubnets), count.index)}"
  security_groups = "${aws_security_group.allow_all.id}"
  az_letters = "${module.vpc.az_letters}"
  networkprefix = "${var.networkprefix}"
  account = "${var.account}"
  aws_key_location = "${var.aws_key_location}"
}

