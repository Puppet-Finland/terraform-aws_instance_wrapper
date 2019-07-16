variable "ami" {}
# Setting "count" to 0 is equivalent to "ensure => absent" in Puppet
variable "count" {
  default = 1
}
variable "default_root_block_device" {
  type = "list"
}
variable "deployment" {}
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
variable "provisioning_ssh_key" {}
variable "provisioning_user" {
  default = "ubuntu"
}
variable "puppetmaster_ip" {}
variable "subnet_id" {}
variable "tags" {
  type    = "map"
  default = {}
}
variable "vpc_security_group_ids" {
    type = "list"
}
