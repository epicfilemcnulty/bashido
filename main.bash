# Bashido 
# Copyright © 2015-2016 Vladimir Zorin
# Licensed under GPLv3, see the full license in 
# the LICENSE file in root folder of the project

# The path to the dir where you put Bashido
# If it's not yet set, we assume the default ${HOME}/.bashido
export BASHIDO=${BASHIDO:-${HOME}/.bashido}    

bashido.show_doc () {
<<SELFDOC
# USAGE: 
#   bashido.show_doc functionName    
#
# DESCRIPTION: 
#   Checks if bash function functionName has self documentation, and, if that
#   is the case, prints it out. Self documentation is a special heredoc string
#   inside the function's code, quite obviously expected to contain documentation
#   of the function. There is also an auxilary complete function, so you
#   can use the full power of tab completion.
#
SELFDOC

    local theCaller="${1}"
    local sS="S"            # We need this trick to avoid our sed pattern 
                            # matching the line containing definition of the
                            # pattern itself (see below).

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    draw_separator () {
        local separatorSymbol="-"
        for (( x=1; x<=85; x++))
        do
            echo -en "${separatorSymbol}"
        done
    }

    if ! ( type -t "${theCaller}" &> /dev/null )  then
        bashido.error "No such function" && return 1
    fi

    local selfDoc=$(declare -f "${theCaller}" | sed -n -e "/${sS}ELFDOC/,/${sS}ELFDOC/p"|sed -e '1d' -e '$d')
    [[ -z "${selfDoc}" ]] && echo "No selfdoc for this function has been defined :(" && return 1

    echo -e $(draw_separator)

    while IFS= read -r line; do
        local fmtline="${line/^#//}"
        echo -e "${fmtline}"
    done <<< "${selfDoc}"

    echo -e $(draw_separator)
}

bashido.functions_list () {
<<SELFDOC
# DESCRIPTION: 
#   This is just an auxilary function to get all names
#   of currently declared bash functions (except those,
#   whose names start with underscore symbol) and use them
#   as bash completion for bashido.show_doc function.
#
#   There is no need to invoke this function manually. Although you certainly can.
SELFDOC

    funcList=$(declare -F|sed 's/declare -f //g'|sed '/^_/d')
    local word=${COMP_WORDS[COMP_CWORD]}
    local fmtList=$(tr '\n' ' ' <<< "${funcList}")
    COMPREPLY=($(compgen -W "${FMTLIST}" "${word}"))
}
complete -F bashido.functions_list bashido.show_doc

bashido.version_compare () {
<<SELFDOC
# USAGE: 
#   bashido.version_compare versionOne versionTwo 
#
# DESCRIPTION: 
#   Expects two string arguments with software versions. The implied format 
#   of the strings in regexp terms is "[0-9]{1,}(\.[1-9][0-9]*)*". In other
#   words there should be no leading zeros after the first dot, otherwise the 
#   result of comparison might be wrong.
#   Returns ">" when versionOne greater than versionTwo, "<" when less and
#   "=" when the versions are equal
SELFDOC

    if bashido.check_args_count 2 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    local ver1=${1//.}
    local ver2=${2//.}

    if [[ $ver1 -gt $ver2 ]]; then
        echo ">"; return 0
    elif    
       [[ $ver1 -lt $ver2 ]]; then
        echo "<"; return 0
    fi 

    echo "="; return 0
}


bashido.check_args_count () {
<<SELFDOC
# USAGE: 
#   bashido.check_args_count requiredArgumentsCount stringWithArguments
#
# DESCRIPTION: 
#   This function returns true when stringWithArguments has only one argument
#   which equals "--help", or when requiredArgumentsCount is greater than
#   the actual number of arguments in the stringWithArguments. 
#   The function should be called from whitin other functions, when they
#   need to check if the expected number of arguments have been
#   provided.
#
# EXAMPLE: 
#   if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi   
#
SELFDOC

    [[ $# -lt 1 || "${1}" == "--help" ]] && bashido.show_doc "${FUNCNAME}" && return 1

    local requiredArgsCount=${1}; shift
    local actualArgsCount=$#

    # There are no arguments provided; none is required, so it's not a cry for help
    [[ ${actualArgsCount} -eq 0 && ${requiredArgsCount} -eq 0 ]] && return 1 
    
    # Well, this one seems serious
    [[ -n ${1} && "${1}" == "--help" ]] && return 0 

    [[ ${requiredArgsCount} -gt ${actualArgsCount} ]] && return 0
    return 1
}

bashido.error() {
<<SELFDOC
# USAGE: 
#   bashido.error "Your error message goes here"
#
# DESCRIPTION: 
#   Just a tiny function to deliver error messages to STDERR.
#
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
    echo "$@" 1>&2
}

bashido.init () {
<<SELFDOC
# USAGE: bashido.init
#
# DESCRIPTION:
#   An init function to source all the modules from the ${BASHIDO}/mods
#   directory. It's called implicitly from the main.bash script, but you
#   can call it explicitly when some of the module files have been changed.
SELFDOC

    if bashido.check_args_count 0 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi
    [[ ! -d ${BASHIDO}/mods ]] && bashido.error "Can't find modules directory"
    
    for mod in ${BASHIDO}/mods/*.bash; do
        source ${mod}
    done
    return 0
}

bashido.init

