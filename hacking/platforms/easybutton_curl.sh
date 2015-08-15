#!/bin/bash

set -e

BRANCH="master"
ARCH=`/bin/uname -m`

if [ `whoami` != 'root' ]; then
    echo "ERROR: must be run as root"
    exit 1
fi

if [ $ARCH != 'x86_64' ]; then
    echo "ERROR: must install on a 64-bit OS"
    exit 1
fi

if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    OS=Debian  # XXX or Ubuntu??
    VER=$(cat /etc/debian_version)
elif [ -f /etc/centos-release ]; then
    OS=CentOS
    VER=`rpm -q --queryformat '%{VERSION}' centos-release`
elif [ -f /etc/redhat-release ]; then
    # TODO add code for Red Hat and CentOS here
    echo "Redhat is not supported, pull requests are appreciated!"
    exit 1
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

case $OS in
    "Ubuntu" )
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y htop build-essential automake autoconf git
        git clone https://github.com/csirtgadgets/massive-octo-spice.git -b $BRANCH
        cd massive-octo-spice
        bash autogen.sh
        sudo bash ./hacking/platforms/easybutton.sh
        sudo chown `whoami`:`whoami` ~/.cif.yml;;

    "Debian" )
        echo 'Debian not yet supported...';;

    "Darwin" )
        echo 'Darwin not yet supported...' ;;

    "Redhat" )
        echo 'Redhat not yet supported...' ;;

    "CentOS" )
        yum -y update && yum -y groupinstall 'Development Tools' && yum -y install htop git wget
        git clone https://github.com/csirtgadgets/massive-octo-spice.git -b $BRANCH
        cd massive-octo-spice
        bash autogen.sh
        sudo bash ./hacking/platforms/easybutton.sh
        sudo chown `whoami`:`whoami` ~/.cif.yml 

esac
