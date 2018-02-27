
variable "vpc_id" {
	description = "The VPC ID to launch the tiered architecture into"
}

variable "cidr_block" {
	description = "The CIDR block of the tier subnet"
}

variable "name" {
	description = "name to be used for tagging instances"
}

variable "user_data" {
	description = "user data to supply to the instance"
}

variable "route_table_id" {
	description = "route table to associate the subnets"
}

variable "ami_id" {
	description = "the id of the ami to spin up in the subnet"
}

variable "map_public_ip_on_launch" {
	default = false
}

variable "ingress" {
	type = "list"
}