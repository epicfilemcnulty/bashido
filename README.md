Table of Contents
===============
* [About](#about)
* [Current status](#status)
* [Requirements](#requirements)
* [Installation](#install)
* [Modules](#modules)
	* [apt](#apt)
	* [cert](#cert)
	* [docker](#docker)
	* [file](#file)
	* [git](#git)
	* [lxd](#lxd)
	* [screen](#screen)

About
=====

Being a sysadmin, devops and a bit of a programmer, I do spend a lot of time in my terminal. There is a good deal of useful utilities in unix/linux CLI world, but sometimes you just feel like writing a small wrapper for one of your favorite/frequently used tools (or a tool chain), to make it more convenient, provide a simpler 'API', add fancy parsing of outputs, etc. 

**Bashido** is an attempt to collect all these wrappers I wrote (or shamelessly copy-pasted from far away sinister corners of the internet, tortured in my digital dungeons for a while, and reissued as perls of my own genius) over the years, structure them and make them easy to (re)use in everyday's CLI life. The wrappers are implemented in bash scripting language, hence the name (bash + japanese term *bushido*, which stands for "the way of warrior", so you may think of **bashido** as the way of the bash warrior).   

**Bashido** is a collection of bash modules. A module is just a set of bash functions that share a common namespace and a common *raison d'etre*, so to say. 

Each module is named after the tool it "wraps", or, if there are several underlying tools, it's named after the main function of these tools. For example, bashido module *file* combines functions to perform different operations with files, but uses several tools to do that.

Module's name also serves as the namespace, all functions within the module are named `module.function`. This approach reflects the structure and benefits CLI usage (in terms of tab completion). 

Please keep in mind that bashido is written mainly for debian-based systems. Of course it may work (at least partly) elsewhere, but my primary focus is on debian-based systems.

Main principles upon which bashido is built:

* Thorough documentation.

Every function is self-documented, help can be displayed by typing `module.function --help` or using an auxiliary function from the bashido main module: `bashido.show_doc module.function`. Moreover, if there is a wrong number of arguments specified when calling a function, self-documentation is also displayed.

* Simplicity.

Don't use extra tools if you can do without them. Ideally, if something can be done with pure bash without becoming a monstrosity, stick to bash.

Each module/function should make it easier to use the underlying tool, it should not complicate things further. If it's easier to use the underlying tool itself than an inteface provided by a function, drop the function and start over.

* Bashism.

Bashido is about bash. So bash specific features, especially the ones which make the code more elegant or shorter, are welcomed here.

* Exemplariness (this one is rather ambitious)

There are lots of guides and articles on how to write bash scripts in the right way. When I started to work on bashido, I was hoping to teach myself the good style of bash coding. I still do. And, although there is yet a very long way to go, hopefully one day it can be labeled as an exemplary specimen of bash scripting. 

Status
====

The current status is beta. Bashido is already usable and quite helpful, but documentation coverage is not complete, some code needs revision, et caetera, et caetera. As soon as I feel it's ready, there will be the first production release. Meanwhile, reviews, critics and suggestions are more than welcomed. 


Requirements
============

Obviously, you must have a **bash** shell. Since bashido is all about providing interfaces (or wrappers) to different CLI tools, to make actual use of it you will have to have relevant tools installed. For example, bashido *git* module assumes that you have *git* package in your system, *docker* module relies on *docker*, etc.

As even a minimal debian installation is certain to have the famous usual suspects, **grep**, **sed**, **awk**, **head**, **tail** and the like, it seemed safe to use these tools where appropriate.

Some functions that perform operations which require super user privileges implicitly use `sudo` to achieve that. So there is no need to explicitly use `sudo` when working with bashido, but, of course, it means that you must have `sudo` installed and configured properly.

Moreover, some functions of a module may rely on related software, e.g. *git.crypt* function relies on *git-crypt* being present. These requirements are specified in each module's description.

Install
=====

Systemwide
---------------------

Clone this repository (or download it as an archive and unpack it) into `/etc/bashido` directory on your system (or any other directory you prefer):

`sudo git clone https://gitlab.com/bashido/bashido.git /etc/bashido`

Now, to have bashido files sourced upon a user's login, add `bashido.sh` file under `/etc/profile.d` directory, which will do the job.

```
cat <<'EOF' | sudo tee /etc/profile.d/bashido.sh

export BASHIDO=/etc/bashido
[[ -r ${BASHIDO}/main.bash ]] && source ${BASHIDO}/main.bash

EOF
```

Locally
------------

```
git clone https://gitlab.com/bashido/bashido.git ~/.bashido
cat <<'EOF' >> ~/.bash_profile

BASHIDO=${HOME}/.bashido
[[ -r ${BASHIDO}/main.bash ]] && source ${BASHIDO}/main.bash

EOF
```

Modules
=====

This section contains only cursory documentation on each module, for the detailed usage instructions please use `module.function --help` option.

apt
----

* **apt.upgrade**
Combines `apt-get update` and `apt-get upgrade`

* **apt.update_repo**
Updates local apt cache for expicitly specified 
repositories only. 

cert
-----

A set of functions to ease work with self-signed certificates, certificate requests, etc. The module uses **openssl** under the hood.

* **cert.init_CA**
Unfortunately, certain certificate operations (generating a certificate request with SANS, or signing a certificate request with localy generated root certificate) can't be performed without external configs -- some options can't be passed as command line arguments to openssl. Therefore, the said external configs should be generated beforehand. This function creates required configs and generates a self-signed root certificate. The function should be invoked before using **cert.sign** or **cert.request**.

* **cert.self_signed**
Generates a self-signed certificate.

* **cert.request**
Generates a certificate request.

* **cert.sign**
Signs a certificate request with locally generated root certificate.

* **cert.trust**
Adds a given certificate to /usr/local/share/ca-certificates, launches update-ca-certificate after that. If firefox and certutil binaries are found in the system, it also adds the certificate to firefox trusted certificates store. 

* **cert.inspect**
Prints out plain text certificate information.

* **cert.req_inspect**
Prints our plain text certificate request information.

docker
---------

* **docker.bash**
Executes /bin/bash inside a given container.

* **docker.bootstrap**
Debootstraps a minimal ubuntu or debian release and imports it as a local docker image.

* **docker.kill**
Stops and removes one or more containers.

* **docker.li**
Lists local docker images.

* **docker.ls**
Lists running containers. Can be invoked via alias **docker.ps**.

* **docker.restart**
Restarts one or more containers.

* **docker.rmi**
Deletes one or more local docker images.

* **docker.run**
Launches a container.

* **docker.set_image**
Sets the name of the image which will be used as base by **docker.run** (when no image name provided).

* **docker.ssh**
Sshs into a container (of course you must have ssh installed and running inside the container for this to work).

file
----

* **file.chext**
Changes file extensions in the current directory.

* **file.encryp**
Encrypts a file using openssl aes-256-cbc encryption.

* **file.decrypt**
Decrypts a file which was encrypted with **file.encrypt**

* **file.rmi**
Removes a file by its' inode number

* **file.swap**
Swaps contents of two files

git
----

* **git.lock**
Locks current git repository using *git-crypt* tool.

* **git.unlock**
Unlocks current git repository.

* **git.stati**
Recursively searches for git repositories starting from the current directory and below. Reports each repo with "dirty" status. Can also perform git pull on every clean repo.
