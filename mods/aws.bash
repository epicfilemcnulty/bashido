# Bashido 
# Copyright © 2015-2016 Vladimir Zorin
# Licensed under GPLv3, see the full license in 
# the LICENSE file in root folder of the project

AWS_PROFILES="${AWS_PROFILES:-${HOME}/.aws/credentials}"

aws.profile () {
<<SELFDOC
# USAGE: aws.profile profileName 
# 
# DESCRIPTION:
#
SELFDOC

    if bashido.check_args_count 0 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi

    profileName=${1}
    profileData=$(sed -n -r "/\[${profileName}\]/,/\[.+\]/p" ${AWS_PROFILES})
    AWS_ACCESS_KEY_ID=$(sed -n -r '/aws_access/s/aws_access_key_id = //p' <<< "${profileData}")
    AWS_SECRET_ACCESS_KEY=$(sed -n -r '/aws_secret/s/aws_secret_access_key = //p' <<< "${profileData}")
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY

}

aws.list_profiles () {

    local list=$(sed -r -n '/\[.+\]/{s/\[|\]//g;p}' ${AWS_PROFILES})
    local word=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W "${list}" "${word}"))
}

complete -F aws.list_profiles aws.profile

