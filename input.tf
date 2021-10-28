variable "ami" {
}

# Setting "amount" to 0 is equivalent to "ensure => absent" in Puppet
variable "amount" {
  type = number
  default = 1
}

variable "associate_public_ip_address" {
  type    = bool
  default = true
}

variable "restart_on_instance_failure" {
  type    = bool
  default = false
}

variable "restart_on_system_failure" {
  type    = bool
  default = false
}

variable "custom_provisioning_scripts" {
  type    = list(string)
  default = []
}

variable "default_root_block_device" {
  type = list(map(string))
}

variable "deployment" {
  type = string
}

# This parameter expects a map in this format:
#
# { ephemeral0 = "/dev/sdb", ephemeral1 = "/dev/sdc" }
#
# Note that this triggers a useless rebuild of the instance if you have
# ephemeral devices attached to it, unless you first remove those devices using
# the AWS CLI. You may want to do this is you're interested in making automatic
# EC2 instance recovery work: it does not work (for whatever reason) if
# instance store (ephemeral) volumes are attached.
#
variable "disabled_ephemeral_block_devices" {
  type = map(string)
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
  type = string
  default = "t2.micro"
}

variable "key_name" {
  type = string
  default = "terraform"
}

variable "private_ip" {
  type    = string
  default = ""
}

variable "provisioning_ssh_key" {
  type = string
}

variable "provisioning_user" {
  type = string
  default = "ubuntu"
}

variable "provision_using_private_ip" {
  type    = bool
  default = true
}

# By default use "deployment" as the Puppet environment name
variable "puppet_environment" {
  type = string
  default = "false"
}

variable "puppet_version" {
  type = number
  default = 6
}

variable "puppetmaster_ip" {
  type = string
}

variable "region" {
  type = string
}

variable "source_dest_check" {
  type    = bool
  default = true
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "volume_tags" {
  type    = map(string)
  default = {}
}

variable "vpc_security_group_ids" {
  type = list(string)
}

