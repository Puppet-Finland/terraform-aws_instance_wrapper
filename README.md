# terraform-aws_instance_wrapper

Create new EC2 instances and join them to a Puppetmaster

# Usage

Most of the parameters map directly into those in aws_instance resource. A few
require some explanation:

* **hostname**: the fully-qualified hostname to use; ends up as certname in Puppet.
* **deployment**: this sets an external fact called "deployment" which can be used in Puppet manifests or Hiera to distinguish between production, staging and testing environments, for example.
* **provisioning_ssh_key**: the local path to the SSH key used with Terraform provisioning; you probably want to set this as an environment variable in a virtualenv.
* **custom_provisioning_scripts**: a list of scripts on the local filesystem to copy and execute on the remote hosts
* **tags**: extra tags to add to the instance; note that this module sets "Name" = "<hostname>" tag automatically.
Example usage:

    module "myserver" {
      source                    = ""
      ami                       = "ami-074e2d6769f445be5"
      hostname                  = "myserver.example.org"
      default_root_block_device = [{ volume_size = 30, delete_on_termination = false }]
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
