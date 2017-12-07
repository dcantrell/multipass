#!/bin/sh
#
# Incoming environment must set:
#     $REPO            Where to write built packages.
#     $SRPMCACHE       SRPMs to build.
#

PATH=/bin:/usr/bin
MACH="$(uname -m)"

# Verify incoming environment
if [ -z "${REPO}" ]; then
    echo "*** Missing REPO." >&2
    exit 1
fi

if [ -z "${SRPMCACHE}" ] || [ ! -d "${SRPMCACHE}" ]; then
    echo "*** Missing SRPMCACHE." >&2
    exit 2
fi

if [ ! -f /etc/os-release ]; then
    echo "*** Missing /etc/os-release." >&2
    exit 3
fi

# Where to write built packages (will clean up after build)
[ -d "${REPO}" ] || mkdir -p "${REPO}"

# Determine our host system
. /etc/os-release
SYSTEM="${ID}-${VERSION_ID}-${MACH}"

# Build all of the SRPM files we have in the cache
find "${SRPMCACHE}" -type f -name "*.src.rpm" | while read srpm ; do
    mock -v -r "${SYSTEM}" --clean

    # XXX: this could probably use an error check, but right now just
    # try to blast through all of the examples
    mock -v -r "${SYSTEM}" \
         --result "${REPO}" \
         --define "_prefix /opt/${ID}/%{name}/%{version}" \
         --rebuild "${srpm}"
done

# Don't care about the log files
rm -f ${REPO}/*.log

# Sort packages in to logical repos
mkdir -p ${REPO}/source
mkdir -p ${REPO}/debug
mkdir -p ${REPO}/${MACH}
mv -v ${REPO}/*-debuginfo*.rpm ${REPO}/debug
mv -v ${REPO}/*-debugsource*.rpm ${REPO}/debug
mv -v ${REPO}/*.src.rpm ${REPO}/source
mv -v ${REPO}/*.rpm ${REPO}/${MACH}

# Create repo metadata
createrepo -v -p ${REPO}/debug
createrepo -v -p ${REPO}/source
createrepo -v -p ${REPO}/${MACH}
