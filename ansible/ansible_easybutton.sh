#!/bin/bash

set -e

BRANCH="develop"
ARCH=`/bin/uname -m`

if [ `whoami` != 'root' ]; then
    echo "ERROR: must be run as root"
    exit 0
fi

if [ $ARCH != 'x86_64' ]; then
    echo "ERROR: must install on a 64-bit OS"
    exit 0
fi

if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
    if [ -z $OS ]; then
        # RedHat LSB doesn't contain all the info in /etc/lsb-release
        OS=`lsb_release -i | cut -s -f 2`
        VER=`lsb_release -r | cut -s -f2 | cut -d. -f 1`
    fi
elif [ -f /etc/debian_version ]; then
    OS="Debian"  # XXX or Ubuntu??
    VER=$(cat /etc/debian_version)
elif [ -f /etc/redhat-release ]; then
    OS="RedHatEnterpriseServer"
    VER=`cat /etc/redhat-release |sed -r -e 's/.*release //' -e 's/\..*//'`
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

case $OS in
    "Ubuntu" )
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y python-pip python-crypto python-httplib2 python-jinja2 python-netaddr python-paramiko python-pkg-resources python-yaml git
        sudo pip install ansible
        if [ -d massive-octo-spice ]; then
            (cd massive-octo-spice && git checkout $BRANCH && git pull)
        else
            git clone https://github.com/csirtgadgets/massive-octo-spice.git -b $BRANCH
        fi
        cd massive-octo-spice/ansible
        ansible-playbook localhost.yml;;  

    "Debian" )
        echo 'Debian not yet supported...';;

    "Darwin" )
        echo 'Darwin not yet supported...' ;;

    "Redhat"|"RedHatEnterpriseServer" )
        if [ $VER == "6" ]; then
            yum -y update && yum install -y wget git && yum -y --setopt=group_package_types=mandatory groupinstall "Development Tools"
            if [ ! -f /etc/yum.repos.d/epel.repo ]; then
                wget "https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm";
                yum -y install ./epel-release-latest-6.noarch.rpm
            fi
            yum -y erase python-crypto && yum -y install python-devel python-pip python-httplib2 python-jinja2 python-netaddr python-setuptools PyYAML
            pip install ansible
            if [ -d massive-octo-spice ]; then
                (cd massive-octo-spice && git checkout $BRANCH && git pull)
            else
                git clone https://github.com/csirtgadgets/massive-octo-spice.git -b $BRANCH
            fi
            cd massive-octo-spice/ansible
            ansible-playbook localhost.yml
        else
            echo "RedHat version $VER is not supported yet..."
        fi
        ;;

    "CentOS" )
        echo 'CentOS not yet supported...' ;;

esac
