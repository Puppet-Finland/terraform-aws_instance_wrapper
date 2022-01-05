# terraform-aws_instance_wrapper

Create new EC2 instances and join them to a Puppetmaster

# Usage

Most of the parameters map directly into those in aws_instance resource. A few
require some explanation:

* **hostname**: the fully-qualified hostname to use; ends up as certname in Puppet.
* **deployment**: this sets an external fact called "deployment" which can be used in Puppet manifests or Hiera to distinguish between production, staging and testing environments, for example.
* **provision_using_private_ip**: when provisioning connect to the private IP of the instance instead of the public IP. Defaults to "false", i.e. to using the public IP.
* **provisioning_ssh_key**: the local path to the SSH key used with Terraform provisioning; you probably want to set this as an environment variable in a virtualenv.
* **custom_provisioning_scripts**: a list of scripts on the local filesystem to copy and execute on the remote hosts. Note that the scripts must call sudo by themselves if they need to elevate their privileges. This is the normal behavior in Terraform. The value of this parameter gets passed to the "scripts" parameter of "remote-exec" provisioner.
* **tags**: extra tags to add to the instance; note that this module sets "Name" = "<hostname>" tag automatically.
* **install_puppet_agent**: install Puppet agent. Defaults to true.
* **puppetmaster_ip**: IP address of the Puppet server. Not set by default which is ok if you are not using a Puppet server or if it can be found using the built-in default name ("puppet").

Example usage:

    module "myserver" {
      source                    = "https://github.com/Puppet-Finland/terraform-aws_instance_wrapper.git"
      ami                       = "ami-074e2d6769f445be5"
      hostname                  = "myserver.example.org"
      default_root_block_device = { volume_size = 30, delete_on_termination = false }
      deployment                = "staging"
      instance_type             = "t2.large"
      key_name                  = "mykey"
      puppetmaster_ip           = "${var.puppetmaster_ip}"
      provisioning_user         = "centos"
      provisioning_ssh_key      = "${var.provisioning_ssh_key}"
      subnet_id                 = "${var.subnet_id}"
      vpc_security_group_ids    = ["${var.vpc_security_group_ids}"]
      tags                      = "${var.tags}"
    }
