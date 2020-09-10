#!/bin/bash
#

function usage() {
    echo "Usage: $(basename ${BASH_SOURCE[0]}) [SRC] [DST]" && exit 1
}

function get-timestamp() {
    stat "$1" 2>/dev/null | grep ^Modify | cut -f2- -d: | sed -e 's/ /-/g;s/:/-/g;s/^-//;' | cut -f1 -d.
}

function get-size() {
    stat "$1" 2>/dev/null | grep Size: | cut -f2- -d: | awk '{print $1}'
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
    [wav]=Music/wav
    [cr2]=Movies/cr2
    [ogg]=Music/ogg
    [mp3]=Music/mp3
    [mp4]=Movies/mp4
    [m4v]=Movies/m4v
    [png]=Pictures/png
    [t02]=Documents/t02
    [doc]=Documents/doc
    [docx]=Documents/doc
    [xls]=Documents/xls
    [xlsx]=Documents/xls
    [ppt]=Documents/ppt
    [pptx]=Documents/ppt
    [odt]=Documents/odt
    [ods]=Documents/ods
    [odp]=Documents/odp
    [pdf]=Documents/pdf
    [zip]=Archives/zip
    [iso]=Images/iso
    [tar.bz2]=Images/tarballs
    [tar.gz]=Images/tarballs
    [tar.xz]=Images/tarballs
    [tgz]=Images/tarballs
)

# get each file type and write to txt files
for t in "${!types[@]}"
do
    { echo "Searching for *.${t} files in ${SRC} ..." && \
	  find "${SRC}" -iname "*.${t}" -type f 2>/dev/null > "${t}-files.txt"; } &
done
wait

# now convert file names to dated file names
SIZE=0
#echo '#!/bin/bash'
for l in *-files.txt
do
    # skip empty files
    [ -z "${l}" ] && continue
    # type is [type]-files.txt
    t=$(echo ${l} | cut -f1 -d-)
    while IFS= read -r f
    do
        SIZE=$((${SIZE}+$(get-size "${f}")))
        sha=$(get-sha256 "${f}")
        ts=$(get-timestamp "${f}")
        yr=$(echo ${ts} | cut -f1 -d-)
        mn=$(echo ${ts} | cut -f2 -d-)
        bn=${DST}/${types[${t}]}/${yr}/${mn}/${ts}-${sha}-$(basename -a "${f}")
	# if this is a renamed rename, trim out the double rename
	bn="$(echo "${bn}" | sed -e "s:\(/${ts}-${sha}-\)${ts}-${sha}-:\1:")"
#        echo install -DCv \"${f}\" \"${bn}\"
#        install -DCv "${f}" "${bn}"
        [ -e "${bn}" ] && echo "${bn} already installed" || install -Dv "${f}" "${bn}"
    done < "${l}"
done

#echo "SIZE=${SIZE} bytes"
# give me contents of ${DST}
#ls -trl "${DST}"
