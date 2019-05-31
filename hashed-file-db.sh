#!/bin/bash
#

function usage() {
    echo "Usage: $(basename ${BASH_SOURCE[0]}) [SRC] [DST]" && exit 1
}

function get-files-by-type() {
    local t=$1; shift
    local s=$1; shift
    find "${s}" -iname "*.${t}" -type f 2>/dev/null
#    find "${s}" -iname "*.${t}" -type f 2>/dev/null | sed -e "s:^\(.*\)$:\'\1\':"
}

function get-timestamp() {
    stat "$1" | grep ^Modify | cut -f2- -d: | sed -e 's/ /-/g;s/:/-/g;s/^-//;' | cut -f1 -d.
}

# check for adequate arguments
[ 2 == $# ] || usage

# get source and destination
SRC=$1; shift
DST=$1; shift

# verify paths exist
for v in SRC DST
do
    [ -d "${!v}" ] || { echo "${BASH_SOURCE[0]}: ERROR: Directory ${!v} not found" && exit 1; }
done

# file types to look for
types=(
    jpg
    jpeg
#    mov
#    wav
#    cr2
#    mp3
#    mp4
#    png
#    doc
#    docx
    xls
    xlsx
#    odt
#    odp
#    ods
#    pdf
#    ppt
#    pptx
#    zip
#    iso
)

# get each file type and write to txt files
for t in "${types[@]}"
do
    get-files-by-type "${t}" "${SRC}" > "${DST}/${t}-files.txt" &
done
wait

# now convert file names to dated file names
for t in "${types[@]}"
do
    # skip empty files
    [ -z "${DST}/${t}-files.txt" ] && continue
    # get file names
    names=()
    while read f
    do
        ts=$(get-timestamp "${f}")
        yr=$(echo ${ts} | cut -f1 -d-)
        mn=$(echo ${ts} | cut -f2 -d-)
        bn=${DST}/${t}/${yr}/${mn}/${ts}-$(basename "${f}")
        echo install -Dcv \"${f}\" \"${bn}\"
    done < "${DST}/${t}-files.txt"
done

# give me contents of ${DST}
#ls -trl "${DST}"
