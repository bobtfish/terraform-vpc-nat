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
variable "azs_list_all" {
  default = "eu-central-1a,eu-central-1b"
}
