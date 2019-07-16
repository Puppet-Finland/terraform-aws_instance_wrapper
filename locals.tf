locals {
  hostname_tag = "${map("Name", "${var.hostname}")}"
  tags = "${merge("${local.hostname_tag}","${var.tags}")}"
}
