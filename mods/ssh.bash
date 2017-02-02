# Bashido 
# Copyright © 2015-2016 Vladimir Zorin
# Licensed under GPLv3, see the full license in 
# the LICENSE file in root folder of the project

SSH_PROFILE_DIR="${SSH_PROFILE_DIR:-${HOME}/.ssh/profiles}"
SSH_KNOWNHOSTS_DIR="${SSH_KNOWNHOSTS_DIR:-${HOME}/.ssh/known_hosts}"

ssh.profile () {
<<SELFDOC
# USAGE: ssh.profile profileName 
# 
# DESCRIPTION:
#
SELFDOC

    if bashido.check_args_count 0 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi

    # If there is no arguments provided we just output the 
    # name of the current profile and exit
    if [[ $# -eq 0 ]]; then
        profileName=$(readlink ${HOME}/.ssh/config)
        profileName=${profileName##*/}
        echo ${profileName}
        return
    fi

    profileName=${1}
    [[ -h ${HOME}/.ssh/config ]] && rm ${HOME}/.ssh/config
    [[ -h ${HOME}/.ssh/hosts ]] && rm ${HOME}/.ssh/hosts
    [[ -h ${HOME}/.ssh/keys ]] && rm ${HOME}/.ssh/keys
    ln -s ${SSH_PROFILE_DIR}/${profileName} ${HOME}/.ssh/config
    ln -s ${SSH_PROFILE_DIR}/keys/${profileName} ${HOME}/.ssh/keys
    ln -s ${SSH_KNOWNHOSTS_DIR}/${profileName} ${HOME}/.ssh/hosts
}

ssh.list_profiles () {

    local list=$(find ${SSH_PROFILE_DIR}/ -maxdepth 1 -type f|sed "s:${SSH_PROFILE_DIR}/::g")
    local word=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W "${list}" "${word}"))
}

complete -F ssh.list_profiles ssh.profile

