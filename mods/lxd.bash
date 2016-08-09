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
#   lxd.ip containerName|containerId
#
# DESCRIPTION
#   Outputs containerName's ip addresses
SELFDOC

    local name=${1}; shift
    lxc info ${name}|egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}'
}

lxd.set_image () {
<<SELFDOC
# USAGE: lxd.set_image imageName
#
# DESCRIPTION:
#   Sets LXD_IMAGE env variable to the imageName.
#   LXD_IMAGE var is used by lxd.run when you omit its second
#   argument, which is expected to be imageName.
#   Upon lxd module init, if LXD_IMAGE var is not set, it
#   will be set to 'server' value
SELFDOC

    if [[ ! -z "${1}" ]]; then
        export LXD_IMAGE="${1}"
    fi  
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
        lxc stop "${container}"
        lxc delete "${container}"
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
        LXD_IMAGE="$image}"
    fi
    lxc launch ${LXD_IMAGE} ${name}
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
    local ip=$(lxd.ip ${name}|head -n1)

    screen.set_name ${name}
    ssh ${ip}
    screen.set_name 'bash'

}

export LXD_IMAGE=${LXD_IMAGE:-server}
