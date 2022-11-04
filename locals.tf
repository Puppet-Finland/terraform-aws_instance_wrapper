locals {
  deployment_tag = { "deployment" = var.deployment }
  hostname_tag   = { "Name" = var.hostname }
  puppet_env     = var.puppet_environment == "false" ? var.deployment : var.puppet_environment
  sns_topic_arn  = var.sns_topic_arn == "none" ? "" : var.sns_topic_arn
  tags           = merge(local.hostname_tag, local.deployment_tag, var.tags)

  run_scripts = {
    hostname             = var.hostname
    deployment           = var.deployment
    puppet_env           = local.puppet_env
    install_puppet_agent = var.install_puppet_agent
    puppet_version       = var.puppet_version
    puppetmaster_ip      = var.puppetmaster_ip
  }
}