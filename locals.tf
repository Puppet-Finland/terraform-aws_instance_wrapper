locals {
  hostname_tag = "${map("Name", "${var.hostname}")}"
  deployment_tag = "${map("deployment", "${var.deployment}")}"
  tags = "${merge("${local.hostname_tag}","${local.deployment_tag}","${var.tags}")}"
}
