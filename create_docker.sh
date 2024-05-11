#!/usr/bin/env bash

docs="Usage:
    bash $0 [options]|-
    $0 [options]

Options:
    -n, --name:           same with the --name of docker, required.

    -p, --publish:        same with the --publish of docker.

    -P, --publish-all:    same with the --publish-all of docker

    -w, --with-gpu:       0 or 1, whether or not to enable gpu, the default value is 1.

    -g, --gpus:           same with the --gpus of docker, when gpu is enabled, the default value is
:                         'all'. When gpu is disabled, the default value is empty.

    -e, --env:            same with the --env of docker, when gpu is enabled, the default value is
:                         'NVIDIA_DRIVER_CAPABILITIES=compute,utility NVIDIA_VISIBLE_DEVICES=all',
:                         you can use more than one -e to specify more than one environment
:                         variable. When gpu is disabled, the default value is empty.

    -d, --distro:         the ditro, the default value is 'ubuntu:latest'.

    -v, --volume:         same with --volume of docker, the default value is empty.

    -f, --file:           a file or a directory will be copied into the new docker. The default
:                         value is './docker_initializer'. If you don't want to copy files into the
:                         docker, you can input 'n' when confirming the command. If you want copy
:                         more than one file, you need put all the files into a directory, then use
:                         '-f dir' to copy the whole directory.

     -a, --auto-install:  whether or not to install automatically, the default value is 1. When
:                         enabled, this will install some basic tools rather than just enter the
:                         new docker.

    --password:    whether or not to add a password for the root user, the default value is
:                         1. When enabled, this will add password for the root user until success.

     -h, --help:          print the manual page.

Example:
    $0 --name newdocker --publish 7777:22 --with-gpu 1 --gpus all -e \\
    NVIDIA_DRIVER_CAPABILITIES=compute,utility -e NVIDIA_VISIBLE_DEVICES=all ubuntu:latest

    $0 -n newdocker -p 7777:22

    $0 --name newdocker --publish 7777:22 --with-gpu 0 --distro ubuntu:latest --file \\
    ./docker_initializer

    $0 -n newdocker -p 7777:22 -w 0

Note:
    The second example will acts same as the first one does.
    The fourth example will acts same as the third one does.
    If you want to pass more than one argument for the same option, you should use more than one
    (e.g., -p 22:22 -p 33:33)."

usage() {
    echo -e "$docs" >&2
    exit "$1"
}

if ! options=$(getopt \
    -o n:p:Pw:g:e:d:v:f:a:h \
    -l name:,publish:,publish-all,with-gpu:,gpus:,env:,distro:,volume:,file:,auto-install:,password:,help \
    -n "$(basename "$0")" -- "$@"); then
    usage 1
fi


eval set -- "$options"
name=()
publish=()
gpus=()
envs=()
volume=()
autoinstall=1
password=1
while true ; do
    case "$1" in
        -n|--name) name+=("--name $2"); pure_name=$2; shift 2;;
        -p|--publish) publish+=("--publish $2"); shift 2;;
        -P|--publish-all) publish_all=--publish-all; shift 1;;
        -w|--with-gpu) with_gpu="$2"; shift 2;;
        -g|--gpus) gpus+=("--gpus $2"); shift 2;;
        -e|--env) envs+=("--env $2"); shift 2;;
        -d|--distro) distro="$2"; shift 2;;
        -v|--volume) volume+=("$2"); shift 2;;
        -f|--file) file_or_dir="$2"; shift 2;;
        -a|--auto-install) autoinstall="$2"; shift 2;;
        --password) password="$2"; shift 2;;
        -h|--help) usage 0;;
        --) shift; break;;
        *) usage 1;;
    esac
done

if [ -z "$pure_name" ]; then
    echo "name can not be empty"
    usage 1
fi

with_gpu=${with_gpu:-1}

if [ "$with_gpu" -eq 1 ]; then
    if [ "${#envs[@]}" -eq 0 ]; then
        envs=("-e NVIDIA_DRIVER_CAPABILITIES=compute,utility -e NVIDIA_VISIBLE_DEVICES=all")
    fi
    if [ "${#gpus[@]}" -eq 0 ]; then
        gpus=("--gpus all")
    fi
else
    envs=()
    gpus=()
fi

if [ -z "$distro" ]; then
    distro=ubuntu:latest
fi

if ! declare -p file_or_dir &>/dev/null; then
    file_or_dir="./docker_initializer"
fi

debug() {
    echo "options:      $options"
    echo "name:         ${name[*]}"
    echo "pure_name:    $pure_name"
    echo "pbulish:      ${publish[*]}"
    echo "publish_all:  $publish_all"
    echo "with_gpu:     ${with_gpu}"
    echo "gpus:         ${gpus[*]}"
    echo "envs:         ${envs[*]}"
    echo "volume:       ${volume[*]}"
    echo "file_or_dir:  $file_or_dir"
    echo "distro:       $distro"
    echo "autoinstall:  $autoinstall"
    echo "password:     $password"
}

sudo_cmd=$(which sudo)

confirm_cmd() {
    echo "The command will be executed: "
    echo "$1"
    while true; do
        echo -n "[Y/n]:"
        read -r confirm
        if [ "$confirm" == 'y' ] || [ "$confirm" == '' ]; then
            if ! bash -c "$1"; then
                exit 1
            fi
            break
        elif [ "$confirm" == 'n' ]; then
            return 1
        fi
    done
    return 0
}

docker_create_cmd="    $sudo_cmd docker run \\
    -dit \\
    ${name[*]} \\
    ${publish[*]} \\
    $publish_all \\
    ${gpus[*]} \\
    ${envs[*]} \\
    ${volume[*]} \\
    $distro"
if ! confirm_cmd "$docker_create_cmd"; then
    echo "terminated"
    exit 1
fi

docker_cp_file_cmd="   $sudo_cmd docker cp \\
    $file_or_dir \\
    $pure_name:/"
if [ "$file_or_dir" != "" ]; then
    if ! confirm_cmd "$docker_cp_file_cmd"; then
        echo "terminated"
        exit 1
    fi
fi

docker_enter_cmd="    $sudo_cmd docker exec \\
    -it ${pure_name} \\
    bash"
if [ "$autoinstall" -eq 1 ] && [ "$file_or_dir" == "./docker_initializer" ]; then
docker_enter_cmd="$docker_enter_cmd \\
    -c \"cd /docker_initializer && bash installer.sh $password\""
fi
if ! confirm_cmd "$docker_enter_cmd"; then
    echo "terminated"
    exit 1
fi

exit 0

