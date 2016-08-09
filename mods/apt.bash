apt.update_repo () {
<<SELFDOC
# USAGE: apt.update_repo filename [filename]
# 
# DESCRIPTION:
#   This function updates local apt cache for expicitly specified 
#   repositories only. The function expects to get one or more filenames
#   within /etc/apt/sources.list.d directory as arguments. This directory is
#   considered to be the default location for any extra repositories you use.
#
#   The function comes with an auxiliary bash completion function, so, having
#   typed apt.update_repo you can hit tab and get a list of files 
#   from /etc/apt/sources.list.d
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi

    for source in "$@"; do
        if [[ -r /etc/apt/sources.list.d/${source} ]]; then
            sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/${source}" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"    
        else
            bashido.error "No such repository file in your /etc/apt/sources.list.d!"
            return 1
        fi
    done
}

apt.repas_list () {

    local ppaList=$(find /etc/apt/sources.list.d/ -name "*.list"|sed 's:/etc/apt/sources.list.d/::')
    local word=${COMP_WORDS[COMP_CWORD]}
    local fmtList=$(tr '\n' ' ' <<< "${ppaList}")
    COMPREPLY=($(compgen -W "${fmtList}" "${word}"))
}

apt.upgrage () {
<<SELFDOC
# USAGE: apt.upgrade
# 
# DESCRIPTION:
#   Just an apt-update && apt-upgrade with sudo shortcut.
SELFDOC

    sudo apt-get update && sudo apt-get upgrade
}

complete -F apt.repas_list apt.update_repo

