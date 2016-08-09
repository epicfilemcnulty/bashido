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

git.enable_prompt() {
<<SELFDOC
#
#
SELFDOC
    local uid=$(/usr/bin/id -u)

    if [[ "${uid}" == "0" ]]; then
        export PS1="\e[0;31m\u@\e[m\e[0;33m\h:\e[m\w\e[48;5;241m\e[38;5;16m\$(git.parse_branch_or_tag)\e[m$ "
    else
        export PS1="\e[0;32m\u@\e[m\e[0;33m\h:\e[m\w\e[48;5;241m\e[38;5;16m\$(git.parse_branch_or_tag)\e[m$ "
    fi

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

git.parse_branch () {
<<SELFDOC
#
#
SELFDOC

  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

git.parse_tag () {
<<SELFDOC
#
#
SELFDOC

  git describe --tags 2> /dev/null
}

git.parse_branch_or_tag() {
<<SELFDOC
#
#
SELFDOC

  local OUT="$(git.parse_branch)"
  if [ "$OUT" == " ((no branch))" ]; then
    OUT="($(git.parse_tag))";
  fi
  echo $OUT
}

