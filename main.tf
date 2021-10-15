resource "aws_instance" "ec2_instance" {
  ami                         = var.ami
  associate_public_ip_address = var.associate_public_ip_address
  count                       = var.amount
  disable_api_termination     = var.disable_api_termination
  ebs_optimized               = var.ebs_optimized
  instance_type               = var.instance_type
  key_name                    = var.key_name
  private_ip                  = var.private_ip
  dynamic "root_block_device" {
    for_each = var.default_root_block_device
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
    }
  }
  source_dest_check      = var.source_dest_check
  subnet_id              = var.subnet_id
  tags                   = local.tags
  volume_tags            = var.volume_tags
  vpc_security_group_ids = var.vpc_security_group_ids

  lifecycle {
    ignore_changes = [
      associate_public_ip_address,
      ebs_optimized,
    ]
  }

  connection {
    type        = "ssh"
    user        = var.provisioning_user
    private_key = file(var.provisioning_ssh_key)
    host        = var.provision_using_private_ip == "true" ? aws_instance.ec2_instance[0].private_ip : aws_instance.ec2_instance[0].public_ip
  }

  provisioner "remote-exec" {
    inline = ["echo ${var.puppetmaster_ip} puppet|sudo tee -a /etc/hosts"]
  }

  provisioner "file" {
    source      = "${path.module}/install-puppet.sh"
    destination = "/tmp/install-puppet.sh"
  }

  provisioner "remote-exec" {
    inline = ["sudo mkdir -p /etc/puppetlabs/facter/facts.d"]
  }

  provisioner "file" {
    content     = "deployment: ${var.deployment}"
    destination = "/tmp/deployment.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/deployment.yaml /etc/puppetlabs/facter/facts.d/",
      "sudo chown -R root:root /etc/puppetlabs/facter",
      "chmod +x /tmp/install-puppet.sh",
      "sudo /tmp/install-puppet.sh -n ${var.hostname} -e ${local.puppet_env} -p ${var.puppet_version} -s",
    ]
  }

  provisioner "remote-exec" {
    scripts = var.custom_provisioning_scripts
  }
}

