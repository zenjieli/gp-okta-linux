#!/usr/bin/env bash

# Tested on Xubuntu 19.10 and CentOS 8

set -e

# make sure script is running as root
if ! [ $(id -u) = 0 ]; then
    >&2 echo "Script should be run as root"
    exit 1
fi

function install_conf {
    if [ ! -f /etc/gp-okta.conf ]; then
        echo 'export VPN_SERVER=' > /etc/gp-okta.conf
    fi
}

function install_gp_saml_gui {
    if [ ! -d /opt/gp-saml-gui ]; then
        git clone https://github.com/dlenski/gp-saml-gui.git /opt/gp-saml-gui
    fi
}

function install_hipreport {
    HIPREPORT_SRC='https://raw.githubusercontent.com/dlenski/openconnect/master/hipreport.sh'
    HIPREPORT_SCRIPT=/usr/libexec/openconnect/hipreport.sh
    # mkdir for sources, if not available
    if [ ! -d /usr/libexec/openconnect ]; then
        mkdir -p /usr/libexec/openconnect
    fi
    # download HIP report script
    if [ ! -f "${HIPREPORT_SCRIPT}" ]; then
        wget -O "${HIPREPORT_SCRIPT}" "${HIPREPORT_SRC}"
        chmod +x "${HIPREPORT_SCRIPT}"
    fi
}

# ubuntu
if ! [[ $(command -v "apt") = "" ]]; then
    apt update
    apt -y install \
        git wget openconnect \
        python3-gi gir1.2-gtk-3.0 gir1.2-webkit2-4.0 \
        python-lxml python-requests
    install_conf
    install_hipreport
    install_gp_saml_gui
# centos
elif ! [[ $(command -v "yum") = "" ]]; then
    yum -y update
    yum -y install epel-release
    yum -y install openconnect vpnc-script
    yum -y install git
    install_conf
    install_hipreport
    install_gp_saml_gui
# unknown
else
    >&2 echo "You are not running a Debian/Red Hat derivative. Sorry."
    exit 1
fi