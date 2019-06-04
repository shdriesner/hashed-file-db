#!/bin/bash
#

function usage() {
    echo "Usage: $(basename ${BASH_SOURCE[0]}) [DST]" && exit 1
}

function get-sha256() {
    s=$(sha256sum "$1" 2>/dev/null | awk '{print $1}')
    echo ${s:0:6}
}

function conv-fn() {
    local f="$1"
    local d=$(dirname "${f}")
    local a=$(basename "${f}" | cut -f-6 -d-)
    local b=$(get-sha256 "${f}")-
    local c=$(basename "${f}" | cut -f7- -d-)
    # 2004-02-12-19-27-00-Micah Mitchell
    echo "${d}/${a}${b}${c}"
}

# check for adequate arguments
[ 1 == $# ] || usage

# get source and destination
DST=$1; shift

# verify paths exist
for v in DST
do
    [ -d "${!v}" ] || { echo "${BASH_SOURCE[0]}: ERROR: Directory ${!v} not found" && exit 1; }
done

# now convert file names to dated file names
echo '#!/bin/bash'
for l in *-mv-files.txt
do
    # skip empty files
    [ -z "${l}" ] && continue
    while read f
    do
	echo mv \"${f}\" \"$(conv-fn "${f}")\"
    done < "${l}"
done
