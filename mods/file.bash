file.encrypt () {
<<SELFDOC
# USAGE: file.encrypt fileName
#
# DESCRIPTION:
#   Encrypts the file fileName using openssl aes-256-cbc 
#   encryption method, and saves encrypted file with the name fileName.enc
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    file="${1}";
    openssl enc -aes-256-cbc -in "${file}" -out "${file}.enc"
}

file.decrypt () {
<<SELFDOC
# USAGE: file.decrypt fileName
#
# DESCRIPTION:
#   Decrypts the file fileName using openssl aes-256-cbc 
#   encryption method. 
#
#   If fileName has '.enc' extension, the decrypted file will be
#   saved with the name fileName, but without that extension.
#   Otherwise, decrypted file will be saved as fileName.dec
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    file="${1}";
    if [[ ! -f ${file%.enc} ]]; then
        outFile=${file%.enc}
    else
        outFile="${file}.dec"
    fi
    openssl enc -aes-256-cbc -d -in "${file}" -out "${outFile}"
}


file.rmi () {
<<SELFDOC
# USAGE: file.rmi inodeNumber
#
# DESCRIPTION: Removes a file which inode equals to inodeNumber
# Use 'ls -i' or 'stat' to get a file's inode number
SELFDOC
    if bashido.check_args_count 1 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi
    find . -inum ${1} -exec rm -i {} \;
}

file.swap () {
<<SELFDOC
# USAGE: file.swap file1 file2
#
# DESCRIPTION: Swaps contents of file1 and file2
SELFDOC
     if bashido.check_args_count 2 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi
     tmp_name="/tmp/TMP_${RANDOM}"
     mv "${1}" "${tmp_name}" && mv "${2}" "${1}" && mv "${tmp_name}" "${2}"
}

file.chext () {
<<SELFDOC
# USAGE: file.chext extension1 [extension2]
#
# DESCRIPTION:
#   If only extension1 is provided, then this function will trim this extension
#   from all the files that have it in the current dir.
#
#   If both extension1 and extension2 are provided, then this function
#   will replace extension1 with extension2 for all the files in the current
#   dir which have extension1
SELFDOC
    if bashido.check_args_count 1 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi
    for files in *.${1}
    do
        if [[ -z "${2}" ]]; then
            mv "$files" "${files%.${1}}"
        else
            mv "$files" "${files%.${1}}.${2}"
        fi
    done

}
