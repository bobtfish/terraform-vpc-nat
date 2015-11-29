output "aws_key_name" {
  value = "${var.aws_key_name}"
}
output "region" {
  value = "${var.region}"
}
output "account" {
  value = "${var.account}"
}
output "az_count" {
  value = "${module.vpc.az_count}"
}
output "az_list" {
  value = "${module.vpc.az_list}"
}
output "frontsubnets" {
  value = "${module.vpc.frontsubnets}"
}
output "dedicatedsubnets" {
    value = "${module.vpc.dedicatedsubnets}"
}
output "ephemeralsubnets" {
    value = "${module.vpc.ephemeralsubnets}"
}
output "public-routetable" {
    value = "${module.vpc.public-routetable}"
}
output "private-routetable" {
    value = "${aws_route_table.private.id}"
}
output "id" {
    value = "${module.vpc.id}"
}
output "cidr_block" {
    value = "${module.vpc.cidr_block}"
}
output "main_route_table_id" {
    value = "${module.vpc.main_route_table_id}"
}
output "default_network_acl_id" {
    value = "${module.vpc.default_network_acl_id}"
}
output "default_security_group_id" {
    value = "${module.vpc.default_security_group_id}"
}
output "security_group_allow_all" {
    value = "${aws_security_group.allow_all.id}"
}
output "nat_instances" {
    value = "${module.instances.instance_ids}"
}
output "nat_public_ips" {
    value = "${module.instances.public_ips}"
}
output "nat_private_ips" {
    value = "${module.instances.private_ips}"
}

