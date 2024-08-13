[English Version](README.md)

# 发布日志
## Release-v0.1.4
* 为`Windows`添加一个创建`ssh-copy-id`的脚本
* 添加`MIT`许可

## Release-v0.1.3
* 修复拼写错误
* 在`docker update --restart=always`命令之前添加`sudo`

## Release-v0.1.2
* 修复了一个错误：`-v`无法使用
* 增加一个选项，可以控制是否在物理机重启时重新启动新的`docker`

## Release-v0.1.1
* 修正一些错别字

## Release-v0.1.0
* 完成脚本基本功能
* 完成`README.md`英文版本

# docker-script
一些用于创建和配置`docker`的脚本。

通常，作为服务器管理员，你需要为某人创建一个新的`docker`并配置`docker`（例如，安装`openssh-server`，配置`sshd`，更新`root`的密码等等）。如果有很多人让你为他们创建新的`dockers`会很麻烦，但是不用担心，这个脚本会帮助你创建一个`docker`并自动配置。

# 如何使用这个脚本?
这部分是为服务器管理员准备的，如果你是`docker`新用户，你可以跳到<a href="#something-for-docker-users">为新用户准备的建议</a>。

## 基本用法
**注意：`apt update`和`apt install ca-certificates`可能很慢。你可以在执行脚本前执行`export all_proxy=http://proxyaddress:port`命令配置代理**

大多数情况下，你只需要创建一个带有或不带有`gpu`的新`docker`，所以简单的使用方法如下：

```bash
# 创建一个带所有`gpu`的`docker`，并自动配置`docker`
bash create_docker.sh -n <new_docker_name> -p <new_port:22>

# 创建一个不带`gpu`的`docker`，并自动配置`docker`
bash create_docker.sh -n <new_docker_name> -p <new_port:22> -w 0
```

第一个命令将创建一个带有所有`gpu`的`docker`，然后自动配置这个`docker`。这种创建与下列命令相同`docker run -dit --name <new_docker_name> --publish <new_port:22> --gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility -e NVIDIA_VISIBLE_DEVICES=all ubuntu:latest`（正如你所看到的，创建一个带有所有`gpu`的新`docker`的命令非常长）。在创建命令中，默认的发行版是`ubuntu:latest`，你可以使用`-d `或`--distro`来指定发行版。创建后，脚本将会复制`./docker_initializer`（配置新`docker`的脚本）到 `new_docker_name:/`中，你可以使用`-f`或`--file`来指定要复制的文件或目录，但通常不需要这样用。这种复制与`docker cp ./docker_initializer <new_docker_name>:/`相同。复制完成后，配置新`docker`的脚本将在新`docker`中执行。这个过程将由`docker exec -it bash -c "cd /docker_initializer && bash installer.sh $password"` 完成（`password`是确定是否配置用户`root`的密码，默认值为`1`，当运行`create_docker.sh`时，你可以使用`--password 0`）。你可以看到，配置过程由`bash -c "cd /docker_initializer && bash installer.sh $password"`完成，这个过程只有在`-f`或`--file`的值与默认值相同时完成，否则就会执行 `docker exec -it bash` （通过`bash`进入`docker`）。

在上述三个进程中，如果任何一个进程失败，脚本将停止，这样你就可以看到它出了什么问题。此外，在执行任何命令之前，脚本会打印将要执行的命令，以便你可以检查该命令是否为你想要的命令，一旦完成检查，你可以按`<CR>`或`y<CR>`(直接按`enter`键或输入`y`然后按`enter`键)，注意你输入的`y`必须是小写的。

## 高级用法
当你创建一个新的`docker`时，你可能想挂载一些目录，你可以使用`-v`或`——volume`来完成。

你可以使用的所有选项如下:

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

# <a id="something-for-docker-users">为`docker`新用户准备的建议</a>
这部分是为一个`docker`新用户准备的。

## 已经完成了什么

首先，你应该知道脚本为你的新`docker`做了什么:
* 更改`apt`的下载源
* 安装`sudo`、`ca-certificates`、`openssh-server`、`vim`和`git`。
* 启用`root`登录和密码登录。
* 为你的首次登录配置一个新密码。

下面简要解释一下为什么要这样做:
* 当`apt`从原始网页下载时，可能非常慢。因此，脚本更改了下载源，以便`apt`可以从`THU`的服务器下载。
* 安装一些基本工具。
* 当`ssh`开启时，它将不允许你以`root`用户或密码登录。配置一个新的`ssh`密钥应该由用户完成（这样他们可以在创建时选择`passphrase`）。因此，该脚本只是打开了这些配置。
* 第一次登录必须有一个新密码，因此脚本会创建一个。

## 接下来应该做什么

**下面这些不仅是你应该为这个`docker`做的事情，也是你每次获得服务器或`docker`时都应该做的事情。**

如果你不做任何配置，`docker`也可以工作，但这可能非常不方便、不安全。

强烈建议做以下的事情:

* 更改你的`root`密码

* 创建一个新用户作为你的登录用户，而不是直接使用`root`，你需要为你的新登录用户添加一个密码

* 配置登录时使用`ssh`而不是密码

让我向你展示一个创建名为`kaiser`的用户的示例（注意你应该将下面所有的`kaiser`更改为你的用户名）：

1. 连接到服务器。

    打开你的终端，然后选择你喜欢的`shell`，在`Windows`中选择`cmd`或`powershell`。注意不推荐使用`cmd`，而是推荐使用`powershell`。如果你有`gitbash`，则强烈推荐使用`gitbash`。在`unix-like `系统中则是`bash`。

    使用`ssh -p port root@address`连接到你的`docker`， `port`和`address`就是服务器管理员告诉你的。输入你的密码（管理员告诉你的密码）。输入正确后，你将进入`docker`（通常在`bash`中会这样）。

2. 更新`root`的密码。

    用这条指令来更新`root`的密码：`sudo passwd`。你只需要输入你的新密码（新密码应该复杂一些，而不是你通常使用的密码，因为你不应该再使用`root`登录）并按`enter`键（你需要执行两次此操作）。

    一旦完成，`root`的密码就被更新了，记住新的密码。

3. 创建一个名为`kaiser`的新用户。

    使用这个命令创建一个名为`kaiser`的用户：`sudo adduser kaiser`。

    一旦你按下回车键，用户将被创建，并要求你输入用户的密码，你只需要输入密码（密码应该是你通常使用的密码，你将使用该用户来操作`docker`）。

    完成密码配置后，命令会询问你更多的信息，你可以按回车键使用默认值。

    现在让我们给`kaiser`所有的`sudo`特权。运行这个`echo 'kaiser ALL=(ALL) ALL' >> /etc/sudoers`。

4. 为`kaiser`配置`ssh`密钥。

    首先，使用`exit`关闭此连接，并确保现在的`shell`是 **你的系统的`shell`** (或者你可以通过打开一个新的终端来完成此操作)。

    如果你没有`ssh`密钥，可能需要创建一个新的。`ssh-keygen`命令会对你有所帮助。简单来说，你只需要在需要你确认的时候按回车键。如果你已经有了一个，就使用之前创建的那个。

    现在你已经有了一个`ssh`密钥，使用这个命令将你的`ssh`密钥上传到`docker`用户`kaiser`: `ssh-copy-id -p port kaiser@address`， `port`和`address`与之前的相同。然后你只需要输入`kaiser`的密码。请注意，在`Windows`中，没有内置的`ssh-copy-id`命令。但是别担心，我找到了一个脚本，它定义了一个名为`ssh-copy-id`的函数。将下面的代码复制到你的`powershell`中（`cmd`不支持，如果你使用的是`git bash`，`ssh-copy-id`是可用的）。然后按回车键，在这之后，你可以在这个`shell`中使用`ssh-copy-id`。然后重新运行命令`ssh-copy-id -p port kaiser@address`。

    如果没有任何错误，恭喜你，你已经完成了。但是你需要做更多的事情来使你的登录更方便。

    为`powershell`创建一个名为`ssh-copy-id`函数的脚本：

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


5. 实现使用`ssh labserver`登录。

    现在你可以使用`ssh -p port kaiser@address`登录你的`docker`，无需输入任何密码。这是可行的，但每次你必须输入`-p port kaiser@address`很不方便。

    首先，你应该找到你的`.ssh`，通常在你的家目录中。假设你的计算机的用户名是`kaiser`，在`Windows`中，它将在`C:\Users\kaiser\.ssh`中，在`unix-like `系统中，将位于`/home/kaiser/.ssh `目录中。

    进入`.ssh`目录，然后创建一个没有任何扩展名的`config`文件（在`Windows`中，你应该注意，必须确保可以看到扩展名，以确保文件名是`config`而不是`config.txt`等），如果已经有这个文件，只需要打开它。现在你已经打开了文件，将下面的内容添加到文件中：

    ```bash
    Host labserver
      HostName address
      User kaiser
      Port port
    ```

    别忘了修改`address`和`port`。用你的用户名代替所有的`kaiser`。保存文件后，你就可以使用`ssh labserver`登录了。

6. 下面这个过程是为了让你的`docker`无法使用`root`用户登录（这一步可选做，但强烈推荐）。

    首先，使用`kaiser`登录`docker`（如果你已经完成了以上所有操作，你可以使用`ssh labserver`登录）。然后将`/etc/ssh/sshd_config`中的`PermitRootLogin yes`修改为`PermitRootLogin no`（使用`sudo vim /etc/ssh/sshd_config`编辑文件）。

    通过命令`sudo service ssh restart `重启你的ssh服务。

    完成后任何人即使用正确的密码或`ssh`密钥，也不能以`root`身份登录。

    你可能会问：如果我真的想以`root`身份登录，应该怎么做 ？你只需要以`kaiser`的身份登录，然后在`docker`上使用`su root`，输入`root`的密码，就可以以`root`身份登录。

7. 下面这个过程是为了让你的`docker`无法使用密码登录（如果你想这样做，请确保现在你可以使用`ssh`密钥登录）。

    首先，使用`kaiser`登录`docker`。然后在`/etc/ssh/sshd_config`中将`PasswordAuthentication no`更改为`PasswordAuthentication yes`（使用`sudo vim /etc/ssh/sshd_config`来编辑文件）。

    通过命令`sudo service ssh restart `重启你的`ssh`服务。

    一旦你完成这个，你就不能用密码登录。这真的很安全，即使有人偷看了你的密码，他们也不能用你的密码登录，除非他们破解了你的`ssh`密钥。

# 我如何为不同的发行版添加更多的脚本
这一部分是为那些想要向仓库添加一些新脚本的人准备的。

如你所见，仓库现在只有适用于`ubuntu`的`install_ubuntu.sh`。但是，如果你想向此存储库做出贡献并使脚本适用于其他发行版也非常容易做到。让我告诉你怎么做。

通常情况下，`create_docker.sh`不需要更新。你只需要更新`docker_initializer/installer.sh`和`docker_initializer/installer_distro.sh`。第一个是选择将要执行的安装程序，其内容如下所示:

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

你需要做的只是添加一个新的`elif`，例如，如果你想为`centos`添加一个新的安装程序，它可能看起来像这样:

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

然后需要更新第二个文件。对于这个例子，你需要在同一个目录下创建一个名为`installer_centos.sh`的文件，写下你要为新发行版做些什么。以下是我在`installer_ubuntu.sh`中所做的：

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

