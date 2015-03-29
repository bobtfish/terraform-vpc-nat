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
    source_dest_check = false
    key_name = "${var.aws_key_name}"
    subnet_id = "${module.vpc.primary-az-frontsubnet}"
    security_groups = ["${aws_security_group.allow_all.id}"]
    tags {
        Name = "nat-primary"
    }
    user_data = "#cloud-config\napt_sources:\n - source: \"deb https://get.docker.io/ubuntu docker main\"\n   keyid: 36A1D7869245C8950F966E92D8576A8BA88D21E9\n - source: \"deb http://apt.puppetlabs.com trusty main\"\n   keyid: 1054b7a24bd6ec30\napt_upgrade: true\nlocale: en_US.UTF-8\npackages:\n - lxc-docker\n - puppet\n - git\nruncmd:\n - [ iptables, -N, LOGGINGF ]\n - [ iptables, -N, LOGGINGI ]\n - [ iptables, -A, LOGGINGF, -m, limit, --limit, 2/min, -j, LOG, --log-prefix, \"IPTables-FORWARD-Dropped: \", --log-level, 4 ]\n - [ iptables, -A, LOGGINGI, -m, limit, --limit, 2/min, -j, LOG, --log-prefix, \"IPTables-INPUT-Dropped: \", --log-level, 4 ]\n - [ iptables, -A, LOGGINGF, -j, DROP ]\n - [ iptables, -A, LOGGINGI, -j, DROP ]\n - [ iptables, -A, FORWARD, -s, ${var.networkprefix}.0.0/16, -j, ACCEPT ]\n - [ iptables, -A, FORWARD, -j, LOGGINGF ]\n - [ iptables, -P, FORWARD, DROP ]\n - [ iptables, -I, FORWARD, -m, state, --state, \"ESTABLISHED,RELATED\", -j, ACCEPT ]\n - [ iptables, -t, nat, -I, POSTROUTING, -s, ${var.networkprefix}.0.0/16, -d, 0.0.0.0/0, -j, MASQUERADE ]\n - [ iptables, -A, INPUT, -s, ${var.networkprefix}.0.0/16, -j, ACCEPT ]\n - [ iptables, -A, INPUT, -p, tcp, --dport, 22, -m, state, --state, NEW, -j, ACCEPT ]\n - [ iptables, -I, INPUT, -m, state, --state, \"ESTABLISHED,RELATED\", -j, ACCEPT ]\n\n - [ iptables, -A, INPUT, -j, LOGGINGI ]\n - [ iptables, -P, INPUT, DROP ]\n - [ /usr/bin/docker, run, --rm, -v, \"/usr/local/bin:/target\", jpetazzo/nsenter ]\n"
    provisioner "remote-exec" {
        inline = [
          "while sudo pkill -0 cloud-init; do sleep 2; done"
        ]
        connection {
          user = "ubuntu"
          key_file = "${var.aws_key_location}"
        }
    }
}

