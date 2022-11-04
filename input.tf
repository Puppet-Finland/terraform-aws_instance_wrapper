variable "ami" {
}

# Setting "amount" to 0 is equivalent to "ensure => absent" in Puppet
variable "amount" {
  type    = number
  default = 1
}

# Whether to install Puppet Agent or not.
variable "install_puppet_agent" {
  type    = bool
  default = true
}

variable "associate_public_ip_address" {
  type    = bool
  default = true
}

# Create Cloudwatch alarm to restart this instance if the instance check fails.
variable "restart_on_instance_failure" {
  type    = bool
  default = false
}

# Create Cloudwatch alarm to restart this instance if the system check fails.
variable "restart_on_system_failure" {
  type    = bool
  default = false
}

# Notify an SNS topic unless set to "none"
variable "sns_topic_arn" {
  type    = string
  default = "none"
}

variable "default_root_block_device" {
  type = list(map(string))
}

variable "deployment" {
  type    = string
  default = ""
}

# This parameter expects a map in this format:
#
# { ephemeral0 = "/dev/sdb", ephemeral1 = "/dev/sdc" }
#
# Note that this triggers a useless rebuild of the instance if you don't have
# any ephemeral (instance store) volumes attached to it. If you do have such
# volumes attached you need to remove those devices using the AWS CLI or adding
# of Cloudwatch alarms will fail (for whatever reason).
#
variable "disabled_ephemeral_block_devices" {
  type    = map(string)
  default = {}
}

# This parameter expects a map in this format:
#
# { "0" = aws_network_interface.foo.id, "1" = aws_network_interface.bar.id }
variable "network_interfaces" {
  type    = map(string)
  default = {}
}

variable "ebs_optimized" {
  type    = bool
  default = true
}

variable "disable_api_termination" {
  type    = bool
  default = true
}

variable "hostname" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "iam_instance_profile" {
  type    = string
  default = ""
}

variable "key_name" {
  type    = string
  default = "terraform"
}

variable "private_ip" {
  type    = string
  default = ""
}

# By default use "deployment" as the Puppet environment name
variable "puppet_environment" {
  type    = string
  default = "false"
}

variable "puppet_version" {
  type    = number
  default = 6
}

variable "puppetmaster_ip" {
  type    = string
  default = ""
}

variable "region" {
  type = string
}

variable "source_dest_check" {
  type    = bool
  default = true
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "volume_tags" {
  type    = map(string)
  default = null
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}

