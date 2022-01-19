locals {
  etc_hosts_command    = var.puppetmaster_ip == "" ? "echo Not modifying /etc/hosts" : "echo ${var.puppetmaster_ip} puppet|sudo tee -a /etc/hosts"
  deployment_tag       = { "deployment" = var.deployment }
  hostname_tag         = { "Name"       = var.hostname   }

  # Command to run to set up the deployment fact for Puppet
  deployment_fact_commands  = ["sudo mkdir -p /etc/facter/facts.d",
                               "sudo mv /tmp/deployment.yaml /etc/facter/facts.d/",
                               "sudo chown -R root:root /etc/facter"]
  # Command to run if install_puppet_agent == true
  puppet_agent_commands = ["chmod +x /tmp/install-puppet.sh",
                          "sudo /tmp/install-puppet.sh -n ${var.hostname} -e ${local.puppet_env} -p ${var.puppet_version} -s"]
  puppet_env           = var.puppet_environment == "false" ? var.deployment : var.puppet_environment
  set_hostname_command = "sudo hostnamectl set-hostname ${var.hostname}"
  sns_topic_arn        = var.sns_topic_arn == "none" ? "" : var.sns_topic_arn
  tags                 = merge(local.hostname_tag, local.deployment_tag, var.tags)
}
