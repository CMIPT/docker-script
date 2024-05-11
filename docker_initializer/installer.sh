#!/usr/bin/env bash

password=$1

sudo_cmd=$(which sudo)

if $sudo_cmd cat /etc/os-release | grep -i ubuntu; then
    $sudo_cmd chmod a+x ./installer_ubuntu.sh
    ./installer_ubuntu.sh "$password"
else
    echo "unexpected: now only support ubuntu docker"
    exit 1
fi

