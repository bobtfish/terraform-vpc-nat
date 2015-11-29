module "vpc" {
    source = "github.com/bobtfish/terraform-vpc"
    region = "${var.region}"
    account = "${var.account}"
    networkprefix = "${var.networkprefix}"
    az_count = "2"
    az_list = "eu-central-1a,eu-central-1b"
}

resource "aws_route_table" "private" {
    count = "${length(split(",", var.azs_list_all))}"
    vpc_id = "${module.vpc.id}"

    tags {
        Name = "${var.region} ${var.account} private"
        type = "private"
        az = "element(split(\",\", module.vpc.az_list_all), count.index)"
    }
}

resource "aws_main_route_table_association" "private" {
    vpc_id = "${module.vpc.id}"
    route_table_id = "${aws_route_table.private.0.id}"
}

resource "aws_route" "default" {
    count = "${length(split(",", var.azs_list_all))}"
    route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
    destination_cidr_block = "0.0.0.0/0"
    instance_id = "${element(split(\",\", module.instances.instance_ids), count.index)}"
}

resource "aws_security_group" "allow_all" {
  name = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id = "${module.vpc.id}"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 0
      to_port = 0
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
  subnet_ids = "${module.vpc.frontsubnets}"
  security_groups = "${aws_security_group.allow_all.id}"
  az_letters = "${module.vpc.az_letters}"
  networkprefix = "${var.networkprefix}"
  account = "${var.account}"
  aws_key_location = "${var.aws_key_location}"
}

