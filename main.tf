# We have to use a provider alias to work around this issue:
#
# <https://github.com/hashicorp/terraform/issues/13018>
#
provider "aws" {
}

resource "aws_instance" "ec2_instance" {
  provider = "aws.${var.region}"
  ami = "${var.ami}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  count = "${var.amount}"
  disable_api_termination = "${var.disable_api_termination}"
  ebs_optimized = "${var.ebs_optimized}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  private_ip = "${var.private_ip}"
  root_block_device = "${var.default_root_block_device}"
  subnet_id = "${var.subnet_id}"
  tags = "${local.tags}"
  volume_tags = "${var.volume_tags}"
  vpc_security_group_ids = [ "${var.vpc_security_group_ids}" ]

  lifecycle {
    ignore_changes = [ "associate_public_ip_address", "ebs_optimized" ]
  }

  connection {
    type = "ssh"
    user = "${var.provisioning_user}"
    private_key = "${file("${var.provisioning_ssh_key}")}"
    host = "${var.provision_using_private_ip == "true" ? aws_instance.ec2_instance.private_ip : aws_instance.ec2_instance.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [ "echo ${var.puppetmaster_ip} puppet|sudo tee -a /etc/hosts" ]
  }


  provisioner "file" {
    source = "${path.module}/install-puppet.sh"
    destination = "/tmp/install-puppet.sh"
  }

  provisioner "remote-exec" {
    inline = [ "sudo mkdir -p /etc/puppetlabs/facter/facts.d" ]
  }

  provisioner "file" {
    content = "deployment: ${var.deployment}"
    destination = "/tmp/deployment.yaml"
  }

  provisioner "remote-exec" {
    inline = [ "sudo mv /tmp/deployment.yaml /etc/puppetlabs/facter/facts.d/",
               "sudo chown -R root:root /etc/puppetlabs/facter",
               "chmod +x /tmp/install-puppet.sh",
               "sudo /tmp/install-puppet.sh ${var.hostname} ${local.puppet_env}" ]
  }

  provisioner "remote-exec" {
    scripts = "${var.custom_provisioning_scripts}"
  }
}
