resource "aws_instance" "ec2_instance" {
  ami                         = var.ami
  associate_public_ip_address = length(var.network_interfaces) > 0 ? null : var.associate_public_ip_address
  count                       = var.amount
  disable_api_termination     = var.disable_api_termination
  ebs_optimized               = var.ebs_optimized
  iam_instance_profile        = var.iam_instance_profile
  instance_type               = var.instance_type
  key_name                    = var.key_name
  private_ip                  = var.private_ip == "" ? null : var.private_ip
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
      tags                  = lookup(root_block_device.value, "tags", null) != null ? jsondecode(lookup(root_block_device.value, "tags")) : null
    }
  }
  source_dest_check      = length(var.network_interfaces) > 0 ? null : var.source_dest_check
  subnet_id              = length(var.network_interfaces) > 0 ? null : var.subnet_id
  tags                   = local.tags
  user_data              = data.cloudinit_config.provision.rendered
  volume_tags            = var.volume_tags
  vpc_security_group_ids = length(var.network_interfaces) > 0 ? null : var.vpc_security_group_ids

  instance_initiated_shutdown_behavior = "stop"

  dynamic "ephemeral_block_device" {
    for_each = var.disabled_ephemeral_block_devices
      content {
        device_name  = ephemeral_block_device.value
        no_device    = "true"
        virtual_name = ephemeral_block_device.key
      }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      network_interface_id = network_interface.value
      device_index         = network_interface.key
    }
  }

  lifecycle {
    ignore_changes = [
      ami,
      associate_public_ip_address,
      ebs_optimized,
      user_data,
    ]
  }
}


# cloud-init config that installs the provisioning scripts
data "local_file" "write_scripts" {
  filename = "${path.module}/write-scripts.cfg"
}

data "cloudinit_config" "provision" {
  gzip          = false
  base64_encode = true

  # The provisioning scripts are embedded using heredoc into a static
  # cloud-init config and gets written to disk using the write_files module. We
  # don't use a template here because Hashicorp in their infinite wisdom chose
  # ${} as the variable interpolation syntax in template files, and this happens
  # to collide with the POSIX shell variable interpolation syntax, and we don't
  # want to change our scripts for that reason alone.
  #
  part {
    content_type = "text/cloud-config"
    content      = data.local_file.write_scripts.content
  }

  # Run the provisioning scripts. This is a template so that we can
  # adjust the parameters passed to the scripts.
  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/run-scripts.cfg.tftpl",
                                {
                                  hostname             = var.hostname,
                                  deployment           = var.deployment,
                                  install_puppet_agent = var.install_puppet_agent,
                                  puppet_env           = local.puppet_env,
                                  puppet_version       = var.puppet_version,
                                  puppetmaster_ip      = var.puppetmaster_ip,
                                  repo_package_url     = var.repo_package_url,
                                  ipv6_only            = var.ipv6_only,
                                }
                               )
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
