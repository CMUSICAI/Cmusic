#!/usr/bin/env bash

OS=${1}
WORKSPACE=${2}
VERSION=${3}

if [[ ! ${OS} || ! ${WORKSPACE} || ! ${VERSION} ]]; then
    echo "Error: Invalid options"
    echo "Usage: ${0} <operating system> <workspace> <version>"
    exit 1
fi

echo "----------------------------------------"
echo "Packaging Build for ${OS}"
echo "----------------------------------------"

RELEASE_DIR="$WORKSPACE/release"
STAGE_DIR="$WORKSPACE/stage/cmusicai-v$VERSION"

mkdir -p $RELEASE_DIR

case $OS in
  windows)
    PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g')
    make deploy
    mv *-setup.exe ${STAGE_DIR}/cmusicai-v$VERSION-win64-setup-unsigned.exe

    make install DESTDIR=${STAGE_DIR}/cmusicai-v$VERSION

    cd ${STAGE_DIR}
    mv cmusicai-v$VERSION/bin/*.dll cmusicai-v$VERSION/lib/
    find . -name "lib*.la" -delete
    find . -name "lib*.a" -delete
    rm -rf cmusicai-v$VERSION/lib/pkgconfig

    find cmusicai-v$VERSION/bin -type f -executable -exec x86_64-w64-mingw32-objcopy --only-keep-debug {} {}.dbg \; -exec x86_64-w64-mingw32-strip -s {} \; -exec x86_64-w64-mingw32-objcopy --add-gnu-debuglink={}.dbg {} \;

    cp -rf ${WORKSPACE}/contrib/windeploy ${RELEASE_DIR}
    mv ${STAGE_DIR}/cmusicai-v$VERSION-win64-setup-unsigned.exe ${RELEASE_DIR}

    ;;
  linux | arm32v7 | aarch64)
    make install DESTDIR=${STAGE_DIR}/cmusicai-v$VERSION

    cd ${STAGE_DIR}
    find . -name "lib*.la" -delete
    find . -name "lib*.a" -delete
    rm -rf cmusicai-v$VERSION/lib/pkgconfig

    if [[ -e ${STAGE_DIR}/cmusicai-v$VERSION/bin ]]; then
        find cmusicai-v$VERSION/bin -type f -executable -exec ${WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    fi
    if [[ -e ${STAGE_DIR}/cmusicai-v$VERSION/lib ]]; then
        find cmusicai-v$VERSION/lib -type f -exec ${WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    fi

    ;;
  *)
    echo "Unknown OS: $OS"
    exit 1
    ;;
esac

cd ${RELEASE_DIR}
for i in cmusicai-v$VERSION-win64-setup-unsigned.exe cmusicai-v$VERSION-x86_64-linux-gnu.tar.gz cmusicai-v$VERSION-aarch64-linux-gnu.tar.gz cmusicai-v$VERSION-arm-linux-gnueabihf.tar.gz; do
    if [[ -e ${i} ]]; then
        md5sum ${i} >> ${i}.md5sum
        sha256sum ${i} >> ${i}.sha256sum
    fi
done