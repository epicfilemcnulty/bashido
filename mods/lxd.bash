# Bashido 
# Copyright © 2015-2016 Vladimir Zorin
# Licensed under GPLv3, see the full license in 
# the LICENSE file in root folder of the project

LXD_NETWORK=${LXD_NETWORK:-lxd0}
LXD_DOMAIN=${LXD_DOMAIN:-lxd}
if [[ -z "${LXD_DNS}" ]]; then
    LXD_DNS=$(lxc network get ${LXD_NETWORK} ipv4.address)
    LXD_DNS=${LXD_DNS%%/*}
fi

lxd.ls () {
<<SELFDOC
# USAGE:
#   lxd.ls [node]
#
# DESCRIPTION: 
#   Lists lxd containers on node (defaults to local) 
SELFDOC

    local node=${1:-local}; shift
    lxc list ${node}:
}

lxd.li () {
<<SELFDOC
# USAGE:
#   lxd.li [node]
#
# DESCRIPTION:
#   Lists lxd images on node (defaults to local)
SELFDOC

    local node=${1:-local}; shift
    lxc image list ${node}:
}

lxd.ip () {
<<SELFDOC
# USAGE:
#   lxd.ip containerName
#
# DESCRIPTION
#   Outputs containerName's ip addresses
SELFDOC

    local name=${1}; shift
    local ip=$(dig +short @${LXD_DNS} ${name}.${LXD_DOMAIN})
    echo ${ip}
}

lxd.kill () {
<<SELFDOC
# USAGE: 
#   lxd.kill containerName|containerId [containerName|containerId]    
#
# DESCRIPTION: 
#   Stops and removes one or more containers, specified by containerName or  
#   containerId.
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    for container in "${@}"; do
        lxc stop --force "${container}" 2>/dev/null
        lxc delete "${container}"
    done
}

lxd.rmi () {
<<SELFDOC
# USAGE:
#   lxd.rmi imageName|imageId [imageName|imageId] [...]
#
# DESCRIPTION:
#   Removes one or more container image(s)
SELFDOC
    
    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
    for image in "${@}"; do
        lxc image delete "${image}"
    done    
}

lxd.run () {
<<SELFDOC
# USAGE: lxd.run containerName|containerId [imageName|imageId]
#
# DESCRIPTION:
#   Starts a container named containerName (hostname of the container 
#   will also be set to this name) in detached mode, based on the image 
#   imageName, or, if imageName is omitted, using LXD_IMAGE
#   env var as the image name.
SELFDOC

    
    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    local name=${1}; shift
    local image=${1}; shift

    if [[ ! -z "${image}" ]]; then
        LXD_IMAGE="${image}"
    fi
    lxc launch ${LXD_IMAGE} ${name}
}

lxd.port () {

    local name=${1}; shift
    local hostPort=${1}; shift
    local containerPort=${1}; shift
 
    local ip=$(lxd.ip ${name})
    iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport ${hostPort} -j DNAT --to ${ip}:${containerPort}

}

lxd.mount () {

    local name=${1}; shift
    local deviceName='data'
    local sourceDir=${1}; shift
    local destDir=${1}; shift

    local containerRootUid=$(awk 'BEGIN {FS=":"} /lxd/ {print $2}' /etc/subuid)
    lxc config device add ${name} ${deviceName} disk source=${sourceDir} path=${destDir}
    sudo chown -R ${containerRootUid} ${sourceDir}
}

lxd.umount () {

    local name=${1}; shift
    local deviceName=${1}; shift
    lxc config device remove ${name} ${deviceName}
}
lxd.bash () {
<<SELFDOC
# USAGE: lxd.bash containerName|containerId 
#
# DESCRIPTION:
#   Interactively executes /bin/bash inside the containerName|containerId.
#   To be precise, it's just a wrapper around 
#   'lxc exec containerName /bin/bash' command.
SELFDOC
    
    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    local name=${1}; shift
    lxc exec ${name} --mode=interactive /bin/bash || lxc exec ${name} --mode=interactive /bin/sh

}

lxd.ssh () {
<<SELFDOC
# USAGE: 
#   lxd.ssh containerName|containerId    
#
# DESCRIPTION: 
#   Uses 'lxd.ip' to get the containerName's ip, and then sshs 
#   into the container. 
#
#   Note that this function assumes that any additional ssh parameters 
#   you need are specified in your ~/.ssh/config file.
#
#   Note as well, that this function also relies on screen.set_name function,
#   cause it sets current screen window name to containerName before sshing 
#   into it, and, upon exit, sets it to 'bash'
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    local name=${1}; shift
    local ip=$(lxd.ip ${name})

    screen.set_name ${name}
    ssh ${ip}
    screen.set_name 'bash'

}

