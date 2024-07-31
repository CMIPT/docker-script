[中文版本](README-zh.md)

# Release Log
## Release-v0.1.4
* Add a script creating ssh-copy-id for Windows
* Add an MIT license

## Release-v0.1.3
* Fix typos
* Add `sudo` before the `docker update --restart=always` command

## Release-v0.1.2
* Fix a bug: `-v` can not work
* Add an option that can control whether or not to restart the new docker when physical machine restarts

## Release-v0.1.1
* Fix some typos

## Release-v0.1.0
* Finish basic functionalities of scripts.
* Finish README.md of English version.

# docker-script
Some scripts for creating and configuring dockers.

Usually, as a server manager, you need create a new docker for someone and configure the docker (e.g., install `oepnssh-server`, configure `sshd`, update the password of `root`, etc.). This can be annoying, if a lot of persons let you create new dockers for them. But, don't worry, this script will help you create a docker and configure it automatically.

# How to Use This?
This part is for the server managers, if you are a user of the new docker, you can jump to [here](#something-for-docker-users).

## Basic Usages
**Note: the `apt update` and `apt install ca-certificates` may be very slow. You can run `export all_proxy=http://proxyaddress:port` to configure proxy before running the script.**

In general, mostly, you just need create a new docker with or with no `gpu`, so the simple way to use it is:

```bash
# create a new docker with all `gpu`s and configure the docker automatically
bash create_docker.sh -n <new_docker_name> -p <new_port:22>

# create a new docker with no `gpu` and configure the docker automatically
bash create_docker.sh -n <new_docker_name> -p <new_port:22> -w 0
```

The first command will create a docker with all `gpu`s, then configure the docker automatically. The creation is same with `docker run -dit --name <new_docker_name> --publish <new_port:22> --gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility -e NVIDIA_VISIBLE_DEVICES=all ubuntu:latest` (as you can see, the command for creating a new docker with all `gpu`s is extremely long). In the creation command, the default distro is `ubuntu:latest`, you can use `-d` or `--distro` to specify the distro. After creation the script will copy `./docker_initializer` (the scripts for configuring a new docker) to `new_docker_name:/`, you can use `-f` or `--file` to specify which file or directory you want to copy, but you usually don't need use this. The copy is same with `docker cp ./docker_initializer <new_docker_name>:/`. After copy, the scripts for configuring a new docker will be executed in the new docker. This process is done by `docker exec -it bash -c "cd /docker_initializer && bash installer.sh $password"` (the variable password is to determine whether or not to configure the password of user `root`, the default value is `1`, you can use `--password 0` when running `create_docker.sh`), As you can see configure process is done by `bash -c "cd /docker_initializer && bash installer.sh $password"`, so this process will only done the `-f` or `--file`'s value is same with the default value, and if it is not, the command will be run `docker exec -it bash` (enter the docker with `bash`).

In the three processes above, if any one fails, the script will stop, so you can see what's wrong with it. Besides, before executing any command before, the script will print what will be executed so that you can check if the command is what you want, once you finish the check, you can press `<CR>` or `y<CR>` (press the enter key directly or input `y` then press enter key), it is worth mentioning that the `y` you input must be a lowercase one.

## Advanced Usages
Maybe when you create a new docker you want to mount some directories, you can use `-v` or `--volume` to do this.

All the options you can use:

```
Usage:
    bash create_docker.sh [options]|-
    ./create_docker.sh [options]

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
:                         docker, you can input 'n' when confirming the command. If you want to copy
:                         more than one file, you need put all the files into a directory, then use
:                         '-f dir' to copy the whole directory.

    -a, --auto-install:   whether or not to install automatically, the default value is 1. When
:                         enabled, this will install some basic tools rather than just enter the
:                         new docker.

    --password:           whether or not to add a password for the root user, the default value is
:                         1. When enabled, this will add password for the root user until success.

    --auto-restart:       whether or not to restart the docker when physical machine restarts. The
:                         default value is 1, you can use --auto-restart 0 to disable this.

    -h, --help:           print the manual page.

Example:
    $0 --name newdocker --publish 7777:22 --with-gpu 1 --gpus all -e \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility -e NVIDIA_VISIBLE_DEVICES=all ubuntu:latest

    $0 -n newdocker -p 7777:22

    $0 --name newdocker --publish 7777:22 --with-gpu 0 --distro ubuntu:latest --file \
    ./docker_initializer

    $0 -n newdocker -p 7777:22 -w 0

Note:
    The second example will acts same as the first one does.
    The fourth example will acts same as the third one does.
    If you want to pass more than one argument for the same option, you should use more than one
    (e.g., -p 22:22 -p 33:33).
```

# Something for Docker Users
This part is for a new docker user.

## What I Already Have?

First, you should have to know what the script have done for your new docker:
* Change the `apt` sources
* Install `sudo`, `ca-certificates`, `openssh-server`, `vim`, and `git`.
* Enable `root` login and password login.
* Configure a new password for your first login.

There are some brief explanations why these will be done:
* When `apt` downloads from the original webs, it may be very slow. Therefore, the script changed the sources so that `apt` can download from `THU`'s server.
* Install some basic tools.
* When `ssh` is on, it will not allow you to login as `root` user or with password. And configure a new `ssh` key should be done by the user (so that they can chose `passphrase` when creating). Therefore, the script just turned on these configurations.
* You must have a new password for the first login, so the script will create a one.

## What Should I Do Next?

**These below are not only what you should do for the docker, but those you should do every time that you get a server or docker.**

If you don't want to do any configurations, the docker may also work, but this may be very inconvenient and unsafe.

These below are strongly recommended:
* Change your `root` password
* Create a new user as your login user rather than using `root` directly, you need add a password for your new login user
* Configure login with `ssh` rather than with password

Let me show you an example creating a user named `kaiser` (note that you should change all the `kaiser`s below to your user name):

1. Let us first connect to the server.

    Open your terminal, and then choose whatever the shell you like, in `Windows` it is `cmd` or `powershell`. It is worth noting that `cmd` is not recommended, `powershell` is recommended, and if you have a `gitbash`, `gitbash` is strongly recommended. In `unix-like` system it is `bash`.

    Connect to your docker using this `ssh -p port root@address`, and the `port` and `address` are those the server manager have told you. Input your password (the password the manager have told you). Once it is correct, you will enter your docker (usually in `bash`).

2. Let us update the `root`'s password.

    Use this to update `root`'s password: `sudo passwd`. You just need enter your new password (the password should be complex and not your usually used password, because you are not supposed to login with root anymore) and press enter (you need do this twice).

    Once this is finished, `root`'s password is updated, keep the new one in mind.

3. Let us create a new user called `kaiser`.

    Use this command to create a user whose name is `kaiser`: `sudo adduser kaiser`.

    Once you press enter key, the user will be created and require you enter the password for the user, you just need enter the password (the password should be your usually used one, you will use the user to operate the docker).

    After finishing configuring your password, the command will ask you some more information, you can just press enter key to use default value.

    Now let us give `kaiser` the all `sudo` privileges. Run this `echo 'kaiser ALL=(ALL) ALL' >> /etc/sudoers`.

4. Let us configure ssh key for `kaiser`.

    First, use `exit` to close this connect, and make sure now the shell is **your system's one** (or you can do this by opening a new terminal).

    If you don't have a ssh key, you may need create a new one. This command will help you: `ssh-keygen`. For simple way, you just need press enter key when it requires your confirm. If you already have one, just use the one you have created before.

    Now you already have a ssh key, use this command to upload your ssh key to the docker for user `kaiser`: `ssh-copy-id -p port kaiser@address`, the `port` and the `address` are same with the before ones. Then you just need input the password of `kaiser`. Note that in `Windows`, there is not a built-in `ssh-copy-id` command. But don't worry, I've found a script that defines a function called `ssh-copy-id`. Copy the code below into your `powershell` (`cmd` does not support this, if you are using `git bash`, `ssh-copy-id` is available). Then press enter key, after this, you can use `ssh-copy-id` in this shell. Then re-run the command `ssh-copy-id -p port kaiser@address`.

    If there is no any error, congratulations, you have done. But you have to do some more to make your login more convenient.

    The script for creating a function called `ssh-copy-id` for `powershell`:

```bash
function ssh-copy-id([string]$userAtMachine, $args){
    $publicKey = "$ENV:USERPROFILE" + "/.ssh/id_rsa.pub"
    if (!(Test-Path "$publicKey")){
        Write-Error "ERROR: failed to open ID file '$publicKey': No such file"
    }
    else {
        & cat "$publicKey" | ssh $args $userAtMachine "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys || exit 1"
    }
}
```

5. Let us do something more to make login with `ssh labserver` possible.

    Now you can use `ssh -p port kaiser@address` to login your docker without inputting any password. This is OK, but every time you must enter `-p port kaiser@address` this is inconvenient.

    First, you should find where your `.ssh` is. This is usually in your home directory. Assume the username of your computer is `kaiser`, in `Windows` it will be in `C:\Users\kaiser\.ssh`, and in `unix-like` system it will be in `/home/kaiser/.ssh`.

    Once you find the `.ssh` directory, enter it. And create a file called `config` without any extension (in `Windows`, you should be careful, and you must make sure you can see the extensions so that the filename is `config` rather than `config.txt`, etc.), and if there has been already one, you just need open it. Now that you have opened the file, append this below to the file:

    ```bash
    Host labserver
      HostName address
      User kaiser
      Port port
    ```
    Don't forget change the `address` and `port`. And don't forget change all `kaiser`s with your username. After saving the file, you can use `ssh labserver` to login.

6. This process is to make your docker unable to login using `root` user (this is optional but strongly recommended).

    First, login the docker with `kaiser` (if you've finished all above, you can use `ssh labserver` to login). Then change the `PermitRootLogin yes` with `PermitRootLogin no` of `/etc/ssh/sshd_config` (use `sudo vim /etc/ssh/sshd_config` to edit the file).

    Restart your ssh service by using this command: `sudo service ssh restart`.

    After finishing this, anyone can not login as `root` even with the right password or ssh key.

    You may ask: if I really want to login as `root`, what should I do? You just login as `kaiser`, then use `su root` on the docker, input the password of `root`, then you can login as `root`.

7. This process is to make your docker unable to login using password (if you want to do this, make sure now you can login with the ssh key).

    First, login the docker with `kaiser`. Then change the `PasswordAuthentication yes` with `PasswordAuthentication no` of `/etc/ssh/sshd_config` (use `sudo vim /etc/ssh/sshd_config` to edit the file).

    Restart your ssh service by using this command: `sudo service ssh restart`.

    Once you finish this, you cannot login with password. This is really safe. Even if someone have peeped your password, they cannot login with your password, unless they have hacked your ssh key.

# How Can I Add Some More Scripts for Different Distros
This part is for someone who wants to add some new scripts to the repository.

As you can see, the repository now only have `install_ubuntu.sh` that works for `ubuntu`. But don't worry if you want to contribute to this repository and make the scripts work for other distros, that is very easy to do. Let me show you how.

Generally, the `create_docker.sh` need no updates. You just need update `docker_initializer/installer.sh` and `docker_initializer/installer_distro.sh` the first one is to chose which installer will be executed, its contents are like the following:

```bash
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
```

What you need to do for this one is simply add a new `elif`, for example, if you want to add a new installer for `centos`, it may look like this:

```bash
#!/usr/bin/env bash

password=$1

sudo_cmd=$(which sudo)

if $sudo_cmd cat /etc/os-release | grep -i ubuntu; then
    $sudo_cmd chmod a+x ./installer_ubuntu.sh
    ./installer_ubuntu.sh "$password"
elif $sudo_cmd cat /etc/os-release | grep -i centos; then
    $sudo_cmd chmod a+x ./installer_centos.sh
    ./installer_centos.sh "$password"
else
    echo "unexpected: now only support ubuntu docker"
    exit 1
fi
```

Then you need to update the second file. For this example, you need create a file named `installer_centos.sh` in the same directory. And write what you want to do for the new distro. Here is what I have done in `installer_ubuntu.sh`:

```bash
#!/usr/bin/env bash

password=$1

sudo_cmd=$(which sudo)

# before changing source, we must install ca-certificates
$sudo_cmd apt update
$sudo_cmd apt install -y ca-certificates

# change the apt source
# this only works for Ubuntu 22.04 and Ubuntu 20.04
# the original source.list will be renamed with source.list.bak
if $sudo_cmd cat /etc/os-release | grep -i ubuntu; then
    $sudo_cmd cp /etc/apt/sources.list /etc/apt/sources.list.bak
    if $sudo_cmd cat /etc/os-release | grep '22\.04'; then
        $sudo_cmd cat ./sources.list.tuna-22.04 | $sudo_cmd tee /etc/apt/sources.list || exit 1
        $sudo_cmd cat ./sources.list.tuna-22.04 | $sudo_cmd tee /etc/apt/sources.list || exit 1
        $sudo_cmd apt update || exit 1
    elif $sudo_cmd cat /etc/os-release | grep '20\.04'; then
        $sudo_cmd cat ./sources.list.tuna-20.04 | $sudo_cmd tee /etc/apt/sources.list || exit 1
        $sudo_cmd apt update || exit 1
    else
        $sudo_cmd echo "unexpected: only support ubuntu-22.04 and ubuntu-20.04" | \
            $sudo_cmd  tee installer-ubuntu.log
    fi
else
    $sudo_cmd echo "unexpected: only support for ubuntu" | $sudo_cmd tee installer-ubuntu.log
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
if ! $sudo_cmd cat /etc/ssh/sshd_config | $sudo_cmd grep "^\s*PermitRootLogin\s\+yes\s*\$"; then
    $sudo_cmd echo "PermitRootLogin yes" | $sudo_cmd tee -a /etc/ssh/sshd_config || exit 1
fi
if ! $sudo_cmd cat /etc/ssh/sshd_config | \
    $sudo_cmd grep "^\s*PasswordAuthentication\s\+yes\s*\$"; then
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
```

