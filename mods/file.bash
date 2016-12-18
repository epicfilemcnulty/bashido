# Bashido 
# Copyright © 2015-2016 Vladimir Zorin
# Licensed under GPLv3, see the full license in 
# the LICENSE file in root folder of the project

file.encrypt () {
<<SELFDOC
# USAGE: file.encrypt fileName
#
# DESCRIPTION:
#   Encrypts the file fileName using openssl aes-256-cbc 
#   encryption method, and saves encrypted file with the name fileName.enc
SELFDOC

    if bashido.check_args_count 1 "$@"; then bashido.show_doc ${FUNCNAME}; return 1; fi

    local file="${1}"; shift
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

    local file="${1}"; shift
    if [[ ! -f ${file%.enc} ]]; then
        local outFile=${file%.enc}
    else
        local outFile="${file}.dec"
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
    
    local inodeNumber=${1}; shift
    find . -inum ${inodeNumber} -exec rm -i {} \;
}

file.swap () {
<<SELFDOC
# USAGE: file.swap file1 file2
#
# DESCRIPTION: Swaps contents of file1 and file2
SELFDOC
     if bashido.check_args_count 2 "$@"; then bashido.show_doc "$FUNCNAME"; return 1; fi
    
     local file1="${1}"; shift
     local file2="${1}"; shift

     local tmp_name="/tmp/TMP_${RANDOM}"
     mv "${file1}" "${tmp_name}" && mv "${file2}" "${file1}" && mv "${tmp_name}" "${file2}"
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

    local ext1="${1}"; shift
    local ext2="${2}"; shift

    for files in *.${ext1}
    do
        if [[ -z "${ext2}" ]]; then
            mv "$files" "${files%.${ext1}}"
        else
            mv "$files" "${files%.${ext1}}.${ext2}"
        fi
    done

}
