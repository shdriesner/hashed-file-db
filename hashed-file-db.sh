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

function get-size() {
    stat "$1" | grep Size: | cut -f2- -d: | awk '{print $1}'
}

function get-sha256() {
    s=$(sha256sum "$1" 2>/dev/null | awk '{print $1}')
    echo ${s:0:6}
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
declare -A types=(
    [jpg]=Pictures/jpg
    [jpeg]=Pictures/jpg
    [mov]=Movies/mov
#    wav
    [cr2]=Movies/cr2
#    [mp3]=Music/mp3
    [mp4]=Movies/mp4
    [m4v]=Movies/m4v
#    png
#    doc
#    docx
#    xls
#    xlsx
#    odt
#    odp
#    ods
    [pdf]=Documents/pdf
#    ppt
#    pptx
#    zip
#    iso
)

# get each file type and write to txt files
for t in "${!types[@]}"
do
    [ -e "${t}-files.txt" ] && continue
    get-files-by-type "${t}" "${SRC}" > "${t}-files.txt" &
done
wait

# now convert file names to dated file names
SIZE=0
echo '#!/bin/bash'
for l in *-files.txt
do
    # skip empty files
    [ -z "${l}" ] && continue
    # type is [type]-files.txt
    t=$(echo ${l} | cut -f1 -d-)
    while read f
    do
        SIZE=$((${SIZE}+$(get-size "${f}")))
        sha=$(get-sha256 "${f}")
        ts=$(get-timestamp "${f}")
        yr=$(echo ${ts} | cut -f1 -d-)
        mn=$(echo ${ts} | cut -f2 -d-)
        bn=${DST}/${types[${t}]}/${yr}/${mn}/${ts}-${sha}-$(basename "${f}")
        echo install -Dcv \"${f}\" \"${bn}\"
#        install -Dcv \"${f}\" \"${bn}\"
    done < "${l}"
done

#echo "SIZE=${SIZE} bytes"
# give me contents of ${DST}
#ls -trl "${DST}"
