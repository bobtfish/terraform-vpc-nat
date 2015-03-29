output "primary-az-frontsubnet" {
  value = "${module.vpc.primary-az-frontsubnet}"
}
output "primary-az-dedicatedsubnet" {
    value = "${module.vpc.primary-az-dedicatedsubnet}"
}
output "primary-az-ephemeralsubnet" {
    value = "${module.vpc.public-routeable}"
}
output "secondary-az-frontsubnet" {
    value = "${module.vpc.public-routeable}"
}
output "secondary-az-dedicatedsubnet" {
    value = "${module.vpc.public-routeable}"
}
output "secondary-az-ephemeralsubnet" {
    value = "${module.vpc.public-routeable}"
}
output "public-routeable" {
    value = "${module.vpc.public-routeable}"
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
output "nat_instance" {
    value = "${aws_instance.nat-primary.id}"
}
output "nat_public_ip" {
    value = "${aws_instance.nat-primary.public_ip}"
}
output "nat_private_ip" {
    value = "${aws_instance.nat-primary.private_ip}"
}

