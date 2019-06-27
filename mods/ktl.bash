# Bashido 
# Copyright © 2015-2016 Vladimir Zorin
# Licensed under GPLv3, see the full license in 
# the LICENSE file in root folder of the project

KUBE_PROFILE_DIR="${KUBE_PROFILE_DIR:-${HOME}/.kube/cfgs}"

ktl.profile () {
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
        profileName=$(readlink ${HOME}/.kube/config)
        profileName=${profileName##*/}
        echo ${profileName}
        return
    fi

    profileName=${1}
    [[ -h ${HOME}/.kube/config ]] && rm ${HOME}/.kube/config
    ln -s ${KUBE_PROFILE_DIR}/${profileName} ${HOME}/.kube/config
}

ktl.list_profiles () {

    local list=$(find ${KUBE_PROFILE_DIR}/ -maxdepth 1 -type f|sed "s:${KUBE_PROFILE_DIR}/::g")
    local word=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W "${list}" "${word}"))
}

complete -F ktl.list_profiles ktl.profile

