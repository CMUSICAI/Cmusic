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

mkdir -p ${WORKSPACE}/release

if [[ ${OS} == "windows" ]]; then
    STRIPPROG="/usr/bin/x86_64-w64-mingw32-strip"
    ${STRIPPROG} ${WORKSPACE}/src/cmusicaid.exe
    ${STRIPPROG} ${WORKSPACE}/src/cmusicai-cli.exe
    ${STRIPPROG} ${WORKSPACE}/src/qt/cmusicai-qt.exe
    mv ${WORKSPACE}/src/cmusicaid.exe ${WORKSPACE}/release
    mv ${WORKSPACE}/src/cmusicai-cli.exe ${WORKSPACE}/release
    mv ${WORKSPACE}/src/qt/cmusicai-qt.exe ${WORKSPACE}/release
else
    cd ${WORKSPACE}/src
    FILES="cmusicaid cmusicai-cli"
    # Include the Qt wallet only if the OS version does not imply wallet is disabled
    if [[ ! ${OS} =~ "disable-wallet" ]]; then
        FILES="${FILES} qt/cmusicai-qt"
    fi
    tar -czvf ${WORKSPACE}/release/cmusicai-${VERSION}-${OS}.tar.gz ${FILES}
fi
