#!/usr/bin/env bash

OS=${1}
GITHUB_WORKSPACE=${2}
VERSION=${3}

if [[ ! ${OS} || ! ${GITHUB_WORKSPACE} || ! ${VERSION} ]]; then
    echo "Error: Invalid options"
    echo "Usage: ${0} <operating system> <github workspace path> <version>"
    exit 1
fi

cd ${GITHUB_WORKSPACE}

# Set the PATH based on the OS
if [[ ${OS} == "windows" ]]; then
    export PATH=${GITHUB_WORKSPACE}/depends/x86_64-w64-mingw32/native/bin:${PATH}
elif [[ ${OS} == "osx" ]]; then
    export PATH=${GITHUB_WORKSPACE}/depends/x86_64-apple-darwin14/native/bin:${PATH}
elif [[ ${OS} == "linux" || ${OS} == "linux-disable-wallet" ]]; then
    export PATH=${GITHUB_WORKSPACE}/depends/x86_64-linux-gnu/native/bin:${PATH}
elif [[ ${OS} == "arm32v7" || ${OS} == "arm32v7-disable-wallet" ]]; then
    export PATH=${GITHUB_WORKSPACE}/depends/arm-linux-gnueabihf/native/bin:${PATH}
elif [[ ${OS} == "aarch64" || ${OS} == "aarch64-disable-wallet" ]]; then
    export PATH=${GITHUB_WORKSPACE}/depends/aarch64-linux-gnu/native/bin:${PATH}
else
    echo "You must pass an OS."
    echo "Usage: ${0} <operating system> <github workspace path> <version>"
    exit 1
fi

# Set up version-related variables
SHORTHASH=$(git rev-parse --short HEAD)
RELEASE_LOCATION="${GITHUB_WORKSPACE}/release"
STAGE_DIR="${GITHUB_WORKSPACE}/stage"

if [[ ! -e ${RELEASE_LOCATION} ]]; then
    mkdir -p ${RELEASE_LOCATION}
fi

if [[ ${GITHUB_BASE_REF} =~ "release" ]]; then
    DISTNAME="cmusicai-${VERSION}"
else
    DISTNAME="cmusicai-${VERSION}-${SHORTHASH}"
fi

if [[ ! -e ${STAGE_DIR} ]]; then
    mkdir -p ${STAGE_DIR}
fi

# Build and package the project based on the OS
if [[ ${OS} == "windows" ]]; then
    make deploy
    mv *-setup.exe ${DISTNAME}-win64-setup-unsigned.exe
    make install DESTDIR=${STAGE_DIR}/${DISTNAME}
    cd ${STAGE_DIR}
    mv ${DISTNAME}/bin/*.dll ${DISTNAME}/lib/
    find . -name "lib*.la" -delete
    find . -name "lib*.a" -delete
    rm -rf ${DISTNAME}/lib/pkgconfig
    find ${DISTNAME}/bin -type f -executable -exec x86_64-w64-mingw32-objcopy --only-keep-debug {} {}.dbg \; -exec x86_64-w64-mingw32-strip -s {} \; -exec x86_64-w64-mingw32-objcopy --add-gnu-debuglink={}.dbg {}
    cd ${RELEASE_LOCATION}
    zip -r ${DISTNAME}-win64.zip ${DISTNAME}
    mv ${GITHUB_WORKSPACE}/${DISTNAME}-win64-setup-unsigned.exe ${RELEASE_LOCATION}

#elif [[ ${OS} == "osx" ]]; then
#    make install-strip DESTDIR=${STAGE_DIR}/${DISTNAME}
#    make osx_volname
#    make deploydir
#    mkdir -p unsigned-app-${DISTNAME}
#    cp osx_volname unsigned-app-${DISTNAME}/
#    cp contrib/macdeploy/detached-sig-apply.sh unsigned-app-${DISTNAME}
#    cp contrib/macdeploy/detached-sig-create.sh unsigned-app-${DISTNAME}
#    cp ${GITHUB_WORKSPACE}/depends/x86_64-apple-darwin14/native/bin/dmg ${GITHUB_WORKSPACE}/depends/x86_64-apple-darwin14/native/bin/genisoimage unsigned-app-${DISTNAME}
#    mv dist unsigned-app-${DISTNAME}
#    cd unsigned-app-${DISTNAME}
#    tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c . | gzip -9n > ${RELEASE_LOCATION}/${DISTNAME}-osx-unsigned.tar.gz
#    make deploy
#    ${GITHUB_WORKSPACE}/depends/x86_64-apple-darwin14/native/bin/dmg dmg "CmusicAI-Core" ${RELEASE_LOCATION}/${DISTNAME}-osx-unsigned.dmg

elif [[ ${OS} == "linux" || ${OS} == "linux-disable-wallet" ]]; then
    make install DESTDIR=${STAGE_DIR}/${DISTNAME}
    cd ${STAGE_DIR}
    find . -name "lib*.la" -delete
    find . -name "lib*.a" -delete
    rm -rf ${DISTNAME}/lib/pkgconfig
    find ${DISTNAME}/bin -type f -executable -exec ${GITHUB_WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    find ${DISTNAME}/lib -type f -exec ${GITHUB_WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c . | gzip -9n > ${RELEASE_LOCATION}/${DISTNAME}-x86_64-linux-gnu.tar.gz

elif [[ ${OS} == "arm32v7" || ${OS} == "arm32v7-disable-wallet" ]]; then
    make install DESTDIR=${STAGE_DIR}/${DISTNAME}
    cd ${STAGE_DIR}
    find . -name "lib*.la" -delete
    find . -name "lib*.a" -delete
    rm -rf ${DISTNAME}/lib/pkgconfig
    find ${DISTNAME}/bin -type f -executable -exec ${GITHUB_WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c . | gzip -9n > ${RELEASE_LOCATION}/${DISTNAME}-arm-linux-gnueabihf.tar.gz

elif [[ ${OS} == "aarch64" || ${OS} == "aarch64-disable-wallet" ]]; then
    make install DESTDIR=${STAGE_DIR}/${DISTNAME}
    cd ${STAGE_DIR}
    find . -name "lib*.la" -delete
    find . -name "lib*.a" -delete
    rm -rf ${DISTNAME}/lib/pkgconfig
    find ${DISTNAME}/bin -type f -executable -exec ${GITHUB_WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c . | gzip -9n > ${RELEASE_LOCATION}/${DISTNAME}-aarch64-linux-gnu.tar.gz

else
    echo "You must pass an OS."
    echo "Usage: ${0} <operating system> <github workspace path> <version>"
    exit 1
fi
