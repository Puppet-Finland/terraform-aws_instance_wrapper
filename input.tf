variable "ami" {}
# Setting "count" to 0 is equivalent to "ensure => absent" in Puppet
variable "count" {
  default = 1
}
variable "associate_public_ip_address" {
  type = "string"
  default = "true"
}

variable "custom_provisioning_scripts" {
  type = "list"
  default = []
}

variable "default_root_block_device" {
  type = "list"
}
variable "deployment" {}
variable "ebs_optimized" {
  type = "string"
  default = "true"
}
variable "disable_api_termination" {
  type = "string"
  default = "true"
}
variable "hostname" {}
variable "instance_type" {
  default = "t2.micro"
}
variable "key_name" {
  default = "terraform"
}
variable "private_ip" {
  type = "string"
  default = ""
}
variable "provisioning_ssh_key" {}
variable "provisioning_user" {
  default = "ubuntu"
}
variable "provision_using_private_ip" {
  type = "string"
  default = "false"
}

# By default use "deployment" as the Puppet environment name
variable "puppet_environment" {
  default = "false"
}
variable "puppetmaster_ip" {}
variable "region" {}
variable "subnet_id" {}
variable "tags" {
  type    = "map"
  default = {}
}

variable "volume_tags" {
  type    = "map"
  default = {}
}

variable "vpc_security_group_ids" {
    type = "list"
}
