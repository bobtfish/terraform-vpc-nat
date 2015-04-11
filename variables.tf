variable "nat_instance_count" {
  default = "${module.vpc.az_count}"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "region" {
  default = "eu-central-1"
}
variable "account" {
}
variable "networkprefix" {
}
variable "aws_key_name" {
}
variable "aws_key_location" {
}

