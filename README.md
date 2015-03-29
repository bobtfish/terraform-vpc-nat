# terraform-vpc-nat

Module to build a VPC and nat machines.

Builds out 2 AZs: primary and secondary, with 3 subnets setup:

  * front (gets a public IP)
  * back (dedicated well known IP machines)
  * ephemeral (elb IPs and ASG managed / auto-scaling machines)

Builds an Internet gateway and a 'public' route table that routes
0.0.0.0/0 by the igw

Builds a NAT machine in the front subnet in the primary az

Inputs:
  * region - default eu-central-1
  * account - The account/profile from your ~/.aws/credentials file
  * networkprefix - The first 2 octets of the IP address for this VPC. E.g. 10.84
  * aws_key_name - The name of an AWS public key to access the NAT instance

Outputs:
  * primary-az-frontsubnet
  * primary-az-dedicatedsubnet
  * primary-az-ephemeralsubnet
  * secondary-az-frontsubnet
  * secondary-az-dedicatedsubnet
  * secondary-az-ephemeralsubnet
  * public-routetable
  * private-routetable
  * id - the vpc id
  * cidr_block
  * main_route_table_id
  * default_network_acl_id
  * default_security_group_id
  * security_group_allow_all
  * nat_instance
  * nat_public_ip
  * nat_private_ip

