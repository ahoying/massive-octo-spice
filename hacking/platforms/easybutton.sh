#!/bin/bash

set -e

if [ `whoami` != 'root' ]; then
    echo "must be run as root"
    exit 1
fi

# Check for an Internet Connection as it is required during installation
HTTP_HOST=http://github.com
if [ -x /usr/bin/wget ]; then
    echo "Checking for an Internet connection"
    wget -q --tries=3 --timeout=10 --spider $HTTP_HOST
    if [[ $? -eq 0 ]]; then
        echo "$HTTP_HOST appears to be available via HTTP"
    else
        echo "$HTTP_HOST does not appear to be available via HTTP"
        echo "Exiting installation"
        exit 1
    fi
else
    echo "/usr/bin/wget does not exist, skipping Internet connection test"
fi

cd hacking/platforms

ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')

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
    # add Redhat code here
    echo "Redhat not currently supported, pull requests are welcome!"
    exit 1
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

case $OS in
    "Ubuntu" )
        if [ $VER != "14.04" ]; then
            echo "Currently only 14.04 LTS is supported"
            echo "We accept Pull Requests! =)"
            exit 1
        else
            cd ubuntu
            bash ./ubuntu.sh
        fi
        ;;

    "Debian" )
        echo 'Debian not yet supported...'
        exit 1;;

    "Darwin" )
        echo 'Darwin not yet supported...'
        exit 1;;

    "Redhat" )
        echo 'Redhat not yet supported...'
        exit 1;;

    "CentOS" )
        if [ $VER != "7" ]; then
               echo "Currently only CentOS 7 is supported"
               echo "Pull requests are welcome!"
               exit 1
        else
               cd centos
               bash ./centos.sh
        fi
        ;;

esac
