ssh.switch () {
<<SELFDOC
# USAGE: ssh.switch configName 
# 
# DESCRIPTION:
#
SELFDOC

    configName=${1}
    if bashido.check_args_count 1 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi
    [[ -h ${HOME}/.ssh/config ]] && rm ${HOME}/.ssh/config
    ln -s ${HOME}/.ssh/configs/${configName} ${HOME}/.ssh/config
}

ssh.configsList () {

    local list=$(find ${HOME}/.ssh/configs/ -type f|sed "s:${HOME}/.ssh/configs/::g")
    local word=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W "${list}" "${word}"))
}

complete -F ssh.configsList ssh.switch

