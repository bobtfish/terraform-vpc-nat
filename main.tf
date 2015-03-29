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
        instance_id = "${aws_instance.nat-primary.id}"
    }

    tags {
        Name = "${var.region} ${var.account} private"
    }
}

resource "aws_main_route_table_association" "a" {
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

module "ami" {
  source = "github.com/bobtfish/terraform-ubuntu-ami"
  region = "${var.region}"
  distribution = "trusty"
  architecture = "amd64"
  virttype = "hvm"
  storagetype = "instance-store"
}

resource "aws_instance" "nat-primary" {
    ami = "${module.ami.ami_id}"
    instance_type = "m3.large"
    tags {
        Name = "nat-primary"
    }
    key_name = "${var.aws_key_name}"
    subnet_id = "${module.vpc.primary-az-frontsubnet}"
    security_groups = ["${aws_security_group.allow_all.id}"]
    tags {
        Name = "nat-primary"
    }
    user_data = "#cloud-config\napt_sources:\n - source: \"deb https://get.docker.io/ubuntu docker main\"\n   keyid: 36A1D7869245C8950F966E92D8576A8BA88D21E9\n - source: \"deb http://apt.puppetlabs.com trusty main\"\n   keyid: 1054b7a24bd6ec30\napt_upgrade: true\nlocale: en_US.UTF-8\npackages:\n - lxc-docker\n - puppet\n - git\nruncmd:\n - [ iptables, -t, nat, -I, POSTROUTING, -s, ${var.networkprefix}.0.0/16, -d, 0.0.0.0/0, -j, MASQUERADE ]\n - [ /usr/bin/docker, run, -d, --name, consul, -p, \"8500:8500\", -p, \"8600:8600/udp\", fhalim/consul ]\n - [ /usr/bin/docker, run, --rm, -v, \"/usr/local/bin:/target\", jpetazzo/nsenter ]\n"
}

