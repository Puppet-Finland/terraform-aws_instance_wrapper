locals {
  deployment_tag       = { "deployment" = var.deployment }
  hostname_tag         = { "Name"       = var.hostname   }

  # Command to run if install_puppet_agent == true
  provisioner_commands = ["echo ${var.puppetmaster_ip} puppet|sudo tee -a /etc/hosts",
                          "sudo mkdir -p /etc/puppetlabs/facter/facts.d",
                          "sudo mv /tmp/deployment.yaml /etc/puppetlabs/facter/facts.d/",
                          "sudo chown -R root:root /etc/puppetlabs/facter",
                          "chmod +x /tmp/install-puppet.sh",
                          "sudo /tmp/install-puppet.sh -n ${var.hostname} -e ${local.puppet_env} -p ${var.puppet_version} -s"]

  puppet_env           = var.puppet_environment == "false" ? var.deployment : var.puppet_environment
  sns_topic_arn        = var.sns_topic_arn == "none" ? "" : var.sns_topic_arn
  tags                 = merge(local.hostname_tag, local.deployment_tag, var.tags)
}
