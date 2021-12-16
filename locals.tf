locals {
  hostname_tag = {
    "Name" = var.hostname
  }
  deployment_tag = {
    "deployment" = var.deployment
  }
  tags       = merge(local.hostname_tag, local.deployment_tag, var.tags)
  puppet_env = var.puppet_environment == "false" ? var.deployment : var.puppet_environment

  sns_topic_arn = var.sns_topic_arn == "none" ? "" : var.sns_topic_arn

}

