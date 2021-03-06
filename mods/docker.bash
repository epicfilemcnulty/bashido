# Bashido 
# Copyright © 2015-2016 Vladimir Zorin
# Licensed under GPLv3, see the full license in 
# the LICENSE file in root folder of the project

# If user is docker group or happens to be root
# we don't need to use sudo, so we just set sudoCmd variable 
# to an empty string 

if ( groups | grep docker > /dev/null ) || [[ "$(id -u)" == "0" ]]; then
    export sudoCmd=''
else
    export sudoCmd=sudo
fi

DOCKER_COMPOSE_DIR="${DOCKER_COMPOSE_DIR:-/etc/docker-compose}"

docker.compose_list () {
    local list=""
    for file in /etc/docker-compose/*.yml; do 
        list="${list}${file##*/}"$'\n'
    done
    local word=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W "${list}" "${word}"))
}
docker.compose () {

    local compose_file="${1}"; shift
    docker-compose -f "${DOCKER_COMPOSE_DIR}/${compose_file}" -p "${compose_file%%.yml}" "${@}"

}

complete -F docker.compose_list docker.compose

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
    sudo tar -c . | ${sudoCmd} docker import --change 'CMD ["/sbin/init"]' - ${imageName}
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
  ${sudoCmd} docker ps "${@}"

}
alias docker.ps='docker.ls'

docker.lvs () {
<<SELFDOC
# USAGE: docker.lvs [optional args]
#
# DESCRIPTION:
#   Lists docker volumes. You man provide
#   any additional arguments that 'docker volume' accepts
SELFDOC

    if bashido.check_args_count 0 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
    ${sudoCmd} docker volume ls "${@}"
}

docker.rmv () {
<<SELFDOC
# USAGE: docker.rmv volumeName|volumeId [volumeName|volumeId]
#
# DESCRIPTION
#   Removes one or more docker volumes
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
    ${sudoCmd} docker volume rm "${@}"
}

docker.rmvall () {
<<SELFDOC
# USAGE: docker.rmvall
#
# DESCRIPTION:
#   Removes ALL docker volumes. Be careful with this one,
#   there is no confirmation before deletion, the function
#   assumes that you know what you are doing.
SELFDOC

    if bashido.check_args_count 0 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
    local volumes=$(docker.lvs -q)
    docker.rmv ${volumes}
}

docker.li () {
<<SELFDOC
# USAGE: docker.li [optional args]
#
# DESCRIPTION:
#   Lists docker images. You can provide additional arguments, 
#   see 'docker images -h' for options.
SELFDOC

  if bashido.check_args_count 0 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
  ${sudoCmd} docker images "${@}"

}

docker.rmi () {
<<SELFDOC
# USAGE: docker.rmi imageName|imageId [imageName|imageId]
#
# DESCRIPTION:
#   Deletes one or more docker images
SELFDOC

  if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
  ${sudoCmd} docker rmi "${@}"

}

docker.ip () {
<<SELFDOC
# USAGE: docker.ip containerName|containerId
#
# DESCRIPTION:
#   Outputs containerName's ip address
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    local containerName="${1}"; shift
    ${sudoCmd} docker inspect --format='{{.NetworkSettings.IPAddress}}' ${containerName}

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
    local ip=$(docker.ip ${containerName})
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
        ${sudoCmd} docker stop ${container} 
        ${sudoCmd} docker rm ${container}
    done

}

docker.killall () {

    local containersList=$(docker.ls -a --format '{{ .Names }}' | tr '\n' ' ')
    docker.kill ${containersList}

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
        ${sudoCmd} docker stop ${container}
        ${sudoCmd} docker start ${container}
    done
}

docker.start () {
<<SELFDOC
# USAGE: docker.start containerName [imageName|imageId]
#
# DESCRIPTION:
#   Starts a container named containerName (hostname of the container 
#   will also be set to this name) in detached mode, based on the image 
#   imageName, or, if imageName is omitted, using DOCKER_IMAGE
#   env var as the image name.
SELFDOC
    
    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    local name=${1}; shift
    local image=${1}; shift
    local cmd="${sudoCmd} docker run -d -t"

    ${cmd} --name ${name} -h ${name} ${image} "${@}"

}

docker.run () {
<<SELFDOC
# USAGE: docker.run imageName [command]
#
# DESCRIPTION:
#   Runs the command in an ephemeral container (container will be removed as
#   soon as the command exits), based on imageName image.  
#   Current directory will be mounted into the container at /code, and
#   container's working directory will be set to /code.
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    local image=${1}; shift
    local cmd="${sudoCmd} docker run --rm -it -v $(pwd):/code -w=/code"
    ${cmd} ${image} "${@}"
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
    local cmd="${sudoCmd} docker exec -i -t"
    local shell=bash

    [[ ! -z "${1}" ]] && shell=sh

    ${cmd} ${name} /bin/${shell} 

}

