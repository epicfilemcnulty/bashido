screen.set_name () {
<<SELFDOC
# USAGE: screen.set_name name
#
# DESCRIPTION: 
#   Sets the name of the current screen window inside a screen session to name
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi

    # when you start a screen session, screen will export SCREENED env var,
    # so we check it before actually trying to set the name
    if [[  -n "${SCREENED}" ]]; then
        echo -ne "\ek${1}\e\\"
    fi
}


