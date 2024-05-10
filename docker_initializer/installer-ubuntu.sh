#!/usr/bin/env bash

password=$1

sudo_cmd=$(which sudo)

# before changing source, we must install ca-certificates
$sudo_cmd apt update
$sudo_cmd apt install -y ca-certificates

# install lsb_release
if ! which lsb_release; then
    $sudo_cmd apt update
    $sudo_cmd apt install -y lsb-release
    # this is unlikely to happen
    if ! which lsb_release; then
        echo "unexpected: there is no lsb_release and installation failed"
    fi

fi

# change the apt source
# this only works for Ubuntu 22.04 and Ubuntu 20.04
# the original source.list will be renamed with source.list.bak
if lsb_release -a | grep -i ubuntu; then
        $sudo_cmd cp /etc/apt/sources.list /etc/apt/sources.list.bak
    if lsb_release -a | grep '22\.04'; then
        $sudo_cmd cat ./sources.list.tuna-22.04 | $sudo_cmd tee /etc/apt/sources.list || exit 1
        $sudo_cmd cat ./sources.list.tuna-22.04 | $sudo_cmd tee /etc/apt/sources.list || exit 1
        $sudo_cmd apt update || exit 1
    elif lsb_release -a | grep '20\.04'; then
        $sudo_cmd cat ./sources.list.tuna-20.04 | $sudo_cmd tee /etc/apt/sources.list || exit 1
        $sudo_cmd apt update || exit 1
    else
        ${sudo_cmd} echo "unexpected: only support ubuntu-22.04 and ubuntu-20.04" | \
            ${sudo_cmd}  tee installer-ubuntu.log
    fi
else
    echo "unexpected: only support for ubuntu" | tee installer-ubuntu.log
    exit 1
fi

# install sudo
if ! which sudo; then
    apt install -y sudo
    sudo_cmd=$(which sudo)
fi

# install vim and git
$sudo_cmd apt install -y vim git

# install openssh-server
# you should choose the right time zone
$sudo_cmd apt install -y openssh-server

# config ssh
if ! $sudo_cmd cat /etc/ssh/sshd_config | ${sudo_cmd} grep "^\s*PermitRootLogin\s\+yes\s*\$"; then
    $sudo_cmd echo "PermitRootLogin yes" | $sudo_cmd tee -a /etc/ssh/sshd_config || exit 1
fi
if ! $sudo_cmd cat /etc/ssh/sshd_config | ${sudo_cmd} grep "^\s*PasswordAuthentication\s\+yes\s*\$"; then
    $sudo_cmd echo "PasswordAuthentication yes" | $sudo_cmd tee -a /etc/ssh/sshd_config || exit 1
fi

# restart ssh service
$sudo_cmd service ssh restart

# start ssh when bash start
$sudo_cmd echo "service ssh start" | $sudo_cmd tee -a /root/.bashrc || exit 1

if [ "$password" -eq 1 ]; then
    while ! $sudo_cmd passwd; do
        continue
    done
fi

