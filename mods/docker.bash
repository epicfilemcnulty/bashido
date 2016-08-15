docker.bootstrap () {
<<SELFDOC
# USAGE: docker.bootstrap debian|ubuntu [release] [imageName]
#
# DESCRIPTION:
#   This function will debootstrap a debian or ubuntu release 
#   (defaults to jessie|xenial if release arg is omitted),
#   minbase variant, with one extra package -- runit, into chroot dir 
#   in your current directory, import this debootstrapped image as a 
#   docker image with imageName (defaults to release if omitted), and 
#   remove chroot dir.
#
#   It assumes that your current user has sudo privileges.
#   Keep in mind that if you want to run this function on Ubuntu
#   system in order to debootstrap debian, you should 
#   have debian-archive-keyring package installed.
#    
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    local variant="${1}"; shift

    if [[ "${variant}" == "debian" ]]; then
        local release=${1:-jessie}; shift
        local mirror="http://httpredir.debian.org/debian"
        local cmd="debootstrap --variant=minbase --include=runit"
    elif [[ "${variant}" == "ubuntu" ]]; then 
        local release=${1:-xenial}; shift
        local mirror="http://archive.ubuntu.com/ubuntu/"
        local cmd="debootstrap --variant=minbase --components=main,universe --include=runit"
    fi
    
    local destDir=chroot
    local imageName=${1:-$release}
    local workDir=$(pwd)

    sudo ${cmd} ${release} ${destDir} ${mirror} || return 1

    cd "${destDir}"
    sudo tar -c . | sudo docker import --change 'CMD ["/sbin/init"]' - ${imageName}
    cd -
    sudo rm -rf ${workDir}/${destDir}

}

docker.ls () {
<<SELFDOC
# USAGE: docker.ps [optional args]
#
# DESCRIPTION: 
#   Lists running containers. You can provide additional arguments,
#   e.g. 'docker.ls -a' will list both running and stopped containers.
#   See 'docker ps' -h for options
#
#   This function is also available via alias docker.ps
SELFDOC

  if bashido.check_args_count 0 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
  sudo docker ps "${@}"

}
alias docker.ps='docker.ls'

docker.li () {
<<SELFDOC
# USAGE: docker.li [optional args]
#
# DESCRIPTION:
#   Lists docker images. You can provide additional arguments, 
#   see 'docker images -h' for options.
SELFDOC

  if bashido.check_args_count 0 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
  sudo docker images "${@}"

}

docker.rmi () {
<<SELFDOC
# USAGE: docker.rmi imageName|imageId [imageName|imageId]
#
# DESCRIPTION:
#   Deletes one or more docker images
SELFDOC

  if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
  sudo docker rmi "${@}"

}

docker.set_image () {
<<SELFDOC
# USAGE: docker.set_image imageName
#
# DESCRIPTION:
#   Sets DOCKER_IMAGE env variable to the imageName.
#   DOCKER_IMAGE var is used by docker.run when you omit its second
#   argument, which is expected to be imageName.
#   Upon docker module init, if DOCKER_IMAGE var is not set, it
#   will be set to 'server' value
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
    export DOCKER_IMAGE="${1}"
}

docker.ip () {
<<SELFDOC
# USAGE: docker.ip containerName|containerId
#
# DESCRIPTION:
#   Outputs containerName's ip address
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
    sudo docker inspect --format='{{.NetworkSettings.IPAddress}}' ${containerName}

}

docker.ssh () {
<<SELFDOC
# USAGE: 
#   docker.ssh containerName|containerId    
#
# DESCRIPTION: 
#   Uses 'docker inspect' to get the containerName's ip, and then sshs 
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
    local containerName=${1}
    local ip=$(sudo docker inspect --format='{{.NetworkSettings.IPAddress}}' ${containerName})
    screen.set_name ${containerName}
    ssh ${ip}
    screen.set_name 'bash'
}

docker.kill () {
<<SELFDOC
# USAGE: 
#   docker.kill containerName|containerId [containerName|containerId]    
#
# DESCRIPTION: 
#   Stops and removes one or more containers, specified by containerName or 
#   containerId.
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    for container in "${@}"; do
        sudo docker stop ${container} 
        sudo docker rm ${container}
    done

}

docker.restart () {
<<SELFDOC
# USAGE:
#   docker.restart containerName|containerId [containerName|containerId]
#
# DESCRIPTION:
#   Stops and then starts containerName
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    for container in "${@}"; do
        sudo docker stop ${container}
        sudo docker start ${container}
    done
}

docker.run () {
<<SELFDOC
# USAGE: docker.run containerName [imageName|imageId]
#
# DESCRIPTION:
#   Starts a container named containerName (hostname of the container 
#   will also be set to this name) in detached mode, based on the image 
#   imageName, or, if imageName is omitted, using DOCKER_IMAGE
#   env var as the image name.
SELFDOC
    
    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    local name=${1}; shift
    local cmd='sudo docker run -d -t'

    [[ ! -z "${1}" ]] && DOCKER_IMAGE="${1}"; shift

    ${cmd} --name ${name} -h ${name} ${DOCKER_IMAGE} "${@}"

}

docker.bash () {
<<SELFDOC
# USAGE: docker.bash containerName|containerId [imageName|imageId]
#
# DESCRIPTION:
#   Interactively executes /bin/bash inside containerName|containerId.
#   To be precise, it's just a wrapper around 
#   'docker exec -i -t containerName /bin/bash' command.
SELFDOC
    
    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    local name=${1}; shift
    local cmd='sudo docker exec -i -t'

    [[ ! -z "${1}" ]] 

    ${cmd} ${name} /bin/bash 

}

export DOCKER_IMAGE=${DOCKER_IMAGE:-server}

