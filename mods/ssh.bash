SSH_PROFILE_DIR="${SSH_PROFILE_DIR:-${HOME}/.ssh/profiles}"
SSH_KNOWNHOSTS_DIR="${SSH_KNOWNHOSTS_DIR:-${HOME}/.ssh/known_hosts}"

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
    ln -s ${SSH_PROFILE_DIR}/${profileName} ${HOME}/.ssh/config
    ln -s ${SSH_KNOWNHOSTS_DIR}/${profileName} ${HOME}/.ssh/hosts
}

ssh.list_profiles () {

    local list=$(find ${SSH_PROFILE_DIR}/ -type f|sed "s:${SSH_PROFILE_DIR}/::g")
    local word=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W "${list}" "${word}"))
}

complete -F ssh.list_profiles ssh.profile

