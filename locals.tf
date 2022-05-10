locals {
  deployment_tag       = { "deployment" = var.deployment }
  hostname_tag         = { "Name"       = var.hostname   }
  puppet_env           = var.puppet_environment == "false" ? var.deployment : var.puppet_environment
  sns_topic_arn        = var.sns_topic_arn == "none" ? "" : var.sns_topic_arn
  tags                 = merge(local.hostname_tag, local.deployment_tag, var.tags)
}
