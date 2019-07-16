output "id" {
  value = "${aws_instance.ec2_instance.*.id}"
}
# Use the "splat syntax" to print the IPs of all instances. This is necessary
# to avoid Terraform from complaining when the "count" parameter is set - even
# if it is set to "1".
output "private_ip" {
  value = "${aws_instance.ec2_instance.*.private_ip}"
}
output "public_ip" {
  value = "${aws_instance.ec2_instance.*.public_ip}"
}
