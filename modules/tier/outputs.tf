output "subnet_cidr_block" {
	value = "${var.cidr_block}"
}

output "db_ip" {
  value = "${aws_instance.app-kudz.*.private_ip[0]}"
}

output "app_id" {
  value = "${aws_instance.app-kudz.*.id}"
}

output "sub_n" {
  value = "${aws_subnet.app-kudz.id}"
}

output "sec_group" {
  value = "${aws_security_group.sg_kudz.id}"
}