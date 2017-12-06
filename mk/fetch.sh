#!/bin/sh
#
# Incoming environment must set:
#     $SRPMLIST       Full path to 'srpmlist' file.
#     $SRPMCACHE      Where to write downloaded SRPM files.
#     $CHECKSUMS      Full path to SHA-256 checksums of SRPMs.
#

PATH=/bin:/usr/bin

if [ -z "${SRPMLIST}" ] || [ ! -f "${SRPMLIST}" ]; then
    echo "*** Missing SRPMLIST." >&2
    exit 1
fi

if [ -z "${SRPMCACHE}" ]; then
    echo "*** Missing SRPMCACHE." >&2
    exit 2
fi

if [ -z "${CHECKSUMS}" ] || [ ! -f "${CHECKSUMS}" ]; then
    echo "*** Missing CHECKSUMS." >&2
    exit 3
fi

[ -d "${SRPMCACHE}" ] || mkdir -p "${SRPMCACHE}"

subdir="${SRPMCACHE}"
while read line ; do
    [ -z "${line}" ] && continue
    first="$(echo "${line}" | cut -c1)"
    [ "${first}" = "#" ] && continue

    if [ "${first}" = "[" ]; then
        subdir="${SRPMCACHE}/$(echo "${line}" | cut -d '[' -f 2 | cut -d ']' -f 1)"
        [ -d "${subdir}" ] || mkdir -p "${subdir}"
    else
        srpm="$(basename "${line}")"

        if [ ! -f "${subdir}/${srpm}" ]; then
            echo ">>> ${srpm}"
            curl -# -o "${subdir}/${srpm}" "${line}"
        fi
    fi
done < "${SRPMLIST}"

# XXX: assumes we used SHA-256, if that changes, this command needs to
# determine what is in the checksums file and then run the appropriate
# command
cd "${SRPMCACHE}"
sha256sum -c "${CHECKSUMS}"
exit $?
