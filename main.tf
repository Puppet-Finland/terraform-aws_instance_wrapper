resource "aws_instance" "ec2_instance" {
  ami                         = var.ami
  associate_public_ip_address = var.associate_public_ip_address
  count                       = var.amount
  disable_api_termination     = var.disable_api_termination
  ebs_optimized               = var.ebs_optimized
  iam_instance_profile        = var.iam_instance_profile
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

  instance_initiated_shutdown_behavior = "stop"

  dynamic "ephemeral_block_device" {
    for_each = var.disabled_ephemeral_block_devices
      content {
        device_name  = ephemeral_block_device.value
        no_device    = "true"
        virtual_name = ephemeral_block_device.key
      }
  }

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

  provisioner "file" {
    source      = "${path.module}/install-puppet.sh"
    destination = "/tmp/install-puppet.sh"
  }

  provisioner "file" {
    content     = "deployment: ${var.deployment}"
    destination = "/tmp/deployment.yaml"
  }

  provisioner "remote-exec" {
    inline = concat(["echo Provisioning"], [for command in local.deployment_fact_commands: command if var.deployment != ""])
  }

  provisioner "remote-exec" {
    inline = concat(["echo Provisioning"], [local.set_hostname_command], [local.etc_hosts_command], [for command in local.puppet_agent_commands: command if var.install_puppet_agent])
  }

  provisioner "remote-exec" {
    inline = ["rm -f /tmp/install-puppet.sh /tmp/deployment.yaml"]
  }

  provisioner "remote-exec" {
    scripts = var.custom_provisioning_scripts
  }
}

# Optional restarts if instance or system status checks failed. This is done
# via CloudWatch alarms.
resource "aws_cloudwatch_metric_alarm" "system" {
  count                     = var.restart_on_system_failure == true ? 1 : 0
  alarm_name                = "${var.hostname}_system_check_fail"
  alarm_description         = "System check has failed"
  alarm_actions             = compact(["arn:aws:automate:${var.region}:ec2:recover",
                                       local.sns_topic_arn])
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  dimensions                = { InstanceId: aws_instance.ec2_instance[0].id }
  statistic                 = "Maximum"
  period                    = "300"
  evaluation_periods        = "2"
  datapoints_to_alarm       = "2"
  threshold                 = "1"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  tags                      = { "Name": "${var.hostname}_system_check_fail" }
}

resource "aws_cloudwatch_metric_alarm" "instance" {
  count                     = var.restart_on_instance_failure == true ? 1 : 0
  alarm_name                = "${var.hostname}_instance_check_fail"
  alarm_description         = "Instance check has failed"
  alarm_actions             = compact(["arn:aws:automate:${var.region}:ec2:reboot",
                                       local.sns_topic_arn])
  metric_name               = "StatusCheckFailed_Instance"
  namespace                 = "AWS/EC2"
  dimensions                = { InstanceId: aws_instance.ec2_instance[0].id }
  statistic                 = "Maximum"
  period                    = "300"
  evaluation_periods        = "3"
  datapoints_to_alarm       = "3"
  threshold                 = "1"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  tags                      = { "Name": "${var.hostname}_system_check_fail" }
}
