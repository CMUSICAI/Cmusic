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
echo "Packaging ${OS} Build"
echo "----------------------------------------"

mkdir -p ${WORKSPACE}/release

if [[ ${OS} == "windows" ]]; then
    STRIPPROG="/usr/bin/x86_64-w64-mingw32-strip"
    ${STRIPPROG} ./src/cmusicaid.exe
    ${STRIPPROG} ./src/cmusicai-cli.exe
    ${STRIPPROG} ./src/qt/cmusicai-qt.exe
    install -c -s ./src/cmusicaid.exe ${WORKSPACE}/release
    install -c -s ./src/cmusicai-cli.exe ${WORKSPACE}/release
    install -c -s ./src/qt/cmusicai-qt.exe ${WORKSPACE}/release

    # Create a zip package
    cd ${WORKSPACE}/release
    zip -r cmusicai-${VERSION}-win64.zip *
    mv ${WORKSPACE}/release/cmusicai-${VERSION}-win64.zip ${WORKSPACE}/release/cmusicai-${VERSION}-win64-setup.zip

elif [[ ${OS} == "linux" || ${OS} == "arm32v7" || ${OS} == "aarch64" ]]; then
    STRIPPROG="/usr/bin/strip"
    ${STRIPPROG} ./src/cmusicaid
    ${STRIPPROG} ./src/cmusicai-cli
    install -c -s ./src/cmusicaid ${WORKSPACE}/release
    install -c -s ./src/cmusicai-cli ${WORKSPACE}/release

    # Create a tar package
    cd ${WORKSPACE}/release
    tar -czvf cmusicai-${VERSION}-${OS}.tar.gz *
    mv ${WORKSPACE}/release/cmusicai-${VERSION}-${OS}.tar.gz ${WORKSPACE}/release/cmusicai-${VERSION}-${OS}-setup.tar.gz

else
    echo "Unsupported OS: ${OS}"
    exit 1
fi

echo "Packaging Complete"
