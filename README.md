# terraform-aws_instance_wrapper

Create new EC2 instances and join them to a Puppetmaster

# Usage

Most of the parameters map directly into those in aws_instance resource. A few
require some explanation:

* **hostname**: the fully-qualified hostname to use; ends up as certname in Puppet.
* **deployment**: this sets an external fact called "deployment" which can be used in Puppet manifests or Hiera to distinguish between production, staging and testing environments, for example. If left to the default ("") the $::deployment yaml fact is not created, otherwise it is.
* **tags**: extra tags to add to the instance; note that this module sets "Name" = "<hostname>" tag automatically.
* **install_puppet_agent**: install Puppet agent. Defaults to true.
* **puppetmaster_ip**: IP address of the Puppet server. Not set by default which is ok if you are not using a Puppet server or if it can be found using the built-in default name ("puppet").
* **repo_package_url**: manually define the puppetlabs repo package URL. Use when autodetection does not work or official packages are not yet available for your operating system.
* **ipv6_only**: force use of IPv6 for outbound connections. Currently only affects yum and dnf configuration.
* **hosted_zone_id**: Route53 hosted zone ID where A record ("hostname -> private IP") for this EC2 instance will be added (optional)

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
      subnet_id                 = "${var.subnet_id}"
      vpc_security_group_ids    = ["${var.vpc_security_group_ids}"]
      tags                      = "${var.tags}"
    }
