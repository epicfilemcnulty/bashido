# Bashido 
# Copyright © 2015-2016 Vladimir Zorin
# Licensed under GPLv3, see the full license in 
# the LICENSE file in root folder of the project

git.lock () {
<<SELFDOC
# USAGE: git.lock
#
# DESCRIPTION: Locks current git repo using git-crypt utility
SELFDOC

    if bashido.check_args_count 0 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi
    git-crypt lock

}

git.unlock () {
<<SELFDOC
# USAGE: git.unlock /path/to/your/secret/Key  
#
# DESCRIPTION:
#   Unlocks current git repo (which was locked with the key Key), using
#   git-crypt utility
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi

    local zeKey=${1}; shift
    git-crypt unlock ${zeKey}

}

git.update () {
<<SELFDOC
# USAGE: git.update
#
# DESCRIPTION:
#   Updates the current repository & submodules
SELFDOC

    git pull
    git submodule update --init --recursive
}

git.stati () {
<<SELFDOC
# USAGE: git.stati
#
# DESCRIPTPION:
#   Recursively searches for git repositories starting from the current
#   directory and below. For each found repo execs 'git status' and
#   reports the repo name and changes, when repo's working directory
#   is not clean.
#
SELFDOC

    if bashido.check_args_count 0 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi
    repos=$(find ./ -type d -name '.git')
    baseDir=$(pwd)

    for repo in ${repos}; do
        cd ${repo%.git} 
        changes=$(git status --short)
        if [[ "${changes}" ]]; then
            echo "REPO: ${repo%.git}"
            # We could just echo ${changes} here without
            # invoking 'git status' again, but then we will lose
            # all them pretty colors =)
            git status --short
        else
            if [[ "${1}" == "-p" ]]; then
                echo "${repo%.git} clean, pulling..."
                git pull
            fi
        fi
        cd ${baseDir}
    done

}

