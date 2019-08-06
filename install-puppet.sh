#!/bin/sh
#
# This is a heavily stripped down version of puppet-puppetmaster/vagrant/prepare.sh

# Exit on any error
set -e

export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin

CWD=`pwd`

validate_params() {
    if [ "$1" = "" ]; then
      echo "ERROR: hostname not given as the first parameter!"
      exit 1
    fi
    if [ "$2" = "" ]; then
      echo "ERROR: puppet agent environment not given as the second parameter!"
      exit 1
    fi
}

set_hostname() {
    hostnamectl set-hostname $1
}

detect_osfamily() {
    if [ -f /etc/redhat-release ]; then
        OSFAMILY='redhat'
        RELEASE=$(cat /etc/redhat-release)
	if [ "`echo $RELEASE | grep -E 7\.[0-9]+`" ]; then
            RHEL_VERSION="7"
        else
            echo "Unsupported Redhat/Centos version. Supported versions are 7.x"
            exit 1
        fi
    elif [ "`lsb_release -d | grep -E '(Ubuntu|Debian)'`" ]; then
        OSFAMILY='debian'
        DESCR="$(lsb_release -d | awk '{ print $2}')"
        if [ `echo $DESCR|grep Ubuntu` ]; then
            UBUNTU_VERSION="$(lsb_release -c | awk '{ print $2}')"
        elif [ `echo $DESCR|grep Debian` ]; then
            DEBIAN_VERSION="$(lsb_release -c | awk '{ print $2}')"
        else
            echo "Unsupported Debian family operating system. Supported are Debian and Ubuntu"
            exit 1
        fi
    else
        echo "ERROR: unsupported osfamily. Supported are Debian and RedHat"
        exit 1
    fi
}

setup_puppet() {
    if [ -x /opt/puppetlabs/bin/puppet ]; then
        true
    else
        if [ $RHEL_VERSION ]; then
            RELEASE_URL="https://yum.puppetlabs.com/puppet5/puppet5-release-el-${RHEL_VERSION}.noarch.rpm"
            rpm -hiv "${RELEASE_URL}" || (c=$?; echo "Failed to install ${RELEASE_URL}"; (exit $c))
            yum -y install puppet-agent || (c=$?; echo "Failed to install puppet agent"; (exit $c))
            if systemctl list-unit-files --type=service | grep firewalld; then
                systemctl stop firewalld
                systemctl disable firewalld
                systemctl mask firewalld
            fi
        else
            if [ $UBUNTU_VERSION ]; then
                APT_URL="https://apt.puppetlabs.com/puppet5-release-${UBUNTU_VERSION}.deb"
            fi
            if [ $DEBIAN_VERSION ]; then
                APT_URL="https://apt.puppetlabs.com/puppet5-release-${DEBIAN_VERSION}.deb"
            fi
            # https://serverfault.com/questions/500764/dpkg-reconfigure-unable-to-re-open-stdin-no-file-or-directory
            export DEBIAN_FRONTEND=noninteractive
            FILE="$(mktemp -d)/puppet-release.db"
            wget "${APT_URL}" -qO $FILE || (c=$?; echo "Failed to retrieve ${APT_URL}"; (exit $c))
            # The apt-daily and apt-daily-upgrade services have a nasty habit of
            # launching immediately on boot. This prevents the installer from updating
            # the package caches itself, which causes some packages to be missing and
            # subsequently causing puppetmaster-installer to fail. So, wait for those
            # two services to run before attempting to run the installer. There are
            # ways to use systemd-run to accomplish this rather nicely:
            #
            # https://unix.stackexchange.com/questions/315502/how-to-disable-apt-daily-service-on-ubuntu-cloud-vm-image
            #
            # However, that approach fails on Ubuntu 16.04 (and earlier) as well as
            # Debian 9, so it is not practical. This approach uses a simple polling
            # method and built-in tools.
            while true; do
                fuser -s /var/lib/dpkg/lock || break
                sleep 1
            done

            dpkg --install $FILE; rm $FILE; apt-get update || (c=$?; echo "Failed to install from ${FILE}"; (exit $c))
            apt-get -y install puppet-agent || (c=$?; echo "Failed to install puppet agent"; (exit $c))
        fi
    fi
}

set_puppet_agent_environment() {
    puppet config set --section agent environment $1
}

run_puppet_agent() {
    systemctl enable puppet
    systemctl start puppet
}

validate_params $1 $2
set_hostname $1
detect_osfamily
setup_puppet
set_puppet_agent_environment $2
run_puppet_agent
