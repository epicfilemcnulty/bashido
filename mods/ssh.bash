ssh.profile () {
<<SELFDOC
# USAGE: ssh.profile profileName 
# 
# DESCRIPTION:
#
SELFDOC

    profileName=${1}
    if bashido.check_args_count 1 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi
    [[ -h ${HOME}/.ssh/config ]] && rm ${HOME}/.ssh/config
    [[ -h ${HOME}/.ssh/hosts ]] && rm ${HOME}/.ssh/hosts
    ln -s ${HOME}/.ssh/configs/${profileName} ${HOME}/.ssh/config
    ln -s ${HOME}/.ssh/known_hosts/${profileName} ${HOME}/.ssh/hosts
}

ssh.list_profiles () {

    local list=$(find ${HOME}/.ssh/configs/ -type f|sed "s:${HOME}/.ssh/configs/::g")
    local word=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W "${list}" "${word}"))
}

complete -F ssh.list_profiles ssh.profile

