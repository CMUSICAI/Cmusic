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
RELEASE_LOCATION="${WORKSPACE}/release"

mkdir -p $RELEASE_DIR

DISTNAME="CmusicAI-${VERSION}"

echo "----------------------------------------"
echo "DISTNAME: ${DISTNAME}"
echo "----------------------------------------"

echo "----------------------------------------"
echo "STAGE_DIR: ${STAGE_DIR}"
echo "----------------------------------------"
if [[ ! -e ${STAGE_DIR} ]]; then
    mkdir -p ${STAGE_DIR}
fi

if [[ ${OS} == "windows" ]]; then
    PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g')

    make deploy
    mv *-setup.exe ${DISTNAME}-win64-setup-unsigned.exe

    make install DESTDIR=${STAGE_DIR}/${DISTNAME}

    cd ${STAGE_DIR}
    mv ${DISTNAME}/bin/*.dll ${DISTNAME}/lib/
    find . -name "lib*.la" -delete
    find . -name "lib*.a" -delete
    rm -rf ${DISTNAME}/lib/pkgconfig

    find ${DISTNAME}/bin -type f -executable -exec x86_64-w64-mingw32-objcopy --only-keep-debug {} {}.dbg \; -exec x86_64-w64-mingw32-strip -s {} \; -exec x86_64-w64-mingw32-objcopy --add-gnu-debuglink={}.dbg {} \;

    if [[ -e ${RELEASE_LOCATION} ]]; then
        find ./${DISTNAME} -not -name "*.dbg"  -type f | sort | zip -X@ ./${DISTNAME}-x86_64-w64-mingw32.zip
        mv ./${DISTNAME}-x86_64-*.zip ${RELEASE_LOCATION}/${DISTNAME}-win64.zip
        cp -rf ${WORKSPACE}/contrib/windeploy ${RELEASE_LOCATION}
        cd ${RELEASE_LOCATION}/windeploy
        mkdir unsigned
        mv ${WORKSPACE}/${DISTNAME}-win64-setup-unsigned.exe ${RELEASE_LOCATION}
        find . | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > ${RELEASE_LOCATION}/${DISTNAME}-win64-unsigned.tar.gz
    else
        echo "${RELEASE_LOCATION} doesn't exist"
        exit 1
    fi

    cd ${RELEASE_LOCATION}/
    for i in ${DISTNAME}-win64.zip ${DISTNAME}-win64-setup.exe ${DISTNAME}-win64-setup-unsigned.exe; do
        if [[ -e ${i} ]]; then
            md5sum ${i} >> ${i}.md5sum
            sha256sum ${i} >> ${i}.sha256sum
        else
            echo "${i} doesn't exist"
        fi
    done

    for rmfile in detach-sig-create.sh win-codesign.cert cmusicai-cli.exe cmusicai-qt.exe cmusicaid.exe; do
        if [[ -e ${rmfile} ]]; then
            rm -f ${rmfile}
        fi
    done

elif [[ ${OS} == "osx" ]]; then

    make install-strip DESTDIR=${STAGE_DIR}/${DISTNAME}

    make osx_volname

    make deploydir

    if [[ -e ${WORKSPACE}/dist/CmusicAI-Qt.app/Contents/MacOS/install_cli.sh ]]; then
        chmod +x ${WORKSPACE}/dist/CmusicAI-Qt.app/Contents/MacOS/install_cli.sh
    fi

    mkdir -p unsigned-app-${DISTNAME}
    cp osx_volname unsigned-app-${DISTNAME}/
    cp contrib/macdeploy/detached-sig-apply.sh unsigned-app-${DISTNAME}
    cp contrib/macdeploy/detached-sig-create.sh unsigned-app-${DISTNAME}
    cp ${WORKSPACE}/depends/x86_64-apple-darwin14/native/bin/dmg ${WORKSPACE}/depends/x86_64-apple-darwin14/native/bin/genisoimage unsigned-app-${DISTNAME}
    cp ${WORKSPACE}/depends/x86_64-apple-darwin14/native/bin/x86_64-apple-darwin14-codesign_allocate unsigned-app-${DISTNAME}/codesign_allocate
    cp ${WORKSPACE}/depends/x86_64-apple-darwin14/native/bin/x86_64-apple-darwin14-pagestuff unsigned-app-${DISTNAME}/pagestuff
    mv dist unsigned-app-${DISTNAME}
    cd unsigned-app-${DISTNAME}

    find . | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > ${RELEASE_LOCATION}/${DISTNAME}-osx-unsigned.tar.gz

    cd ${WORKSPACE}

    make deploy

    ${WORKSPACE}/depends/x86_64-apple-darwin14/native/bin/dmg dmg "AIPG-Core.dmg" ${RELEASE_LOCATION}/${DISTNAME}-osx-unsigned.dmg

    cd ${STAGE_DIR}
    find . -name "lib*.la" -delete
    find . -name "lib*.a" -delete
    rm -rf ${DISTNAME}/lib/pkgconfig

    find ${DISTNAME} | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > ${RELEASE_LOCATION}/${DISTNAME}-osx64.tar.gz

    cd ${WORKSPACE}

    if [[ -e ${RELEASE_LOCATION} ]]; then
        cd ${RELEASE_LOCATION}
        for i in ${DISTNAME}-osx-unsigned.tar.gz ${DISTNAME}-osx64.tar.gz ${DISTNAME}-osx-unsigned.dmg; do
            md5sum "${i}" >> ${i}.md5sum
            sha256sum "${i}" >> ${i}.sha256sum
        done
    else
        echo "release directory doesn't exist"
    fi
elif [[ ${OS} == "linux" || ${OS} == "linux-disable-wallet" ]]; then

    make install DESTDIR=${STAGE_DIR}/${DISTNAME}

    cd ${STAGE_DIR}
    find . -name "lib*.la" -delete
    find . -name "lib*.a" -delete
    rm -rf ${DISTNAME}/lib/pkgconfig

    if [[ -e ${STAGE_DIR}/${DISTNAME}/bin ]]; then
        find ${DISTNAME}/bin -type f -executable -exec ${WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    else
        echo "${STAGE_DIR}/${DISTNAME}/bin doesn't exist. $?"
    fi
    if [[ -e ${STAGE_DIR}/${DISTNAME}/lib ]]; then
        find ${DISTNAME}/lib -type f -exec ${WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    else
        echo "${STAGE_DIR}/${DISTNAME}/lib doesn't exist. $?"
    fi

    if [[ -e ${RELEASE_LOCATION} ]]; then
        cd ${STAGE_DIR}
        find ${DISTNAME}/ -not -name "*.dbg" | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > ${RELEASE_LOCATION}/${DISTNAME}-x86_64-linux-gnu.tar.gz
        if [[ -e ${RELEASE_LOCATION}/${DISTNAME}-x86_64-linux-gnu.tar.gz ]]; then
            cd ${RELEASE_LOCATION}
            md5sum ${DISTNAME}-x86_64-linux-gnu.tar.gz >> ${DISTNAME}-x86_64-linux-gnu.tar.gz.md5sum
            sha256sum ${DISTNAME}-x86_64-linux-gnu.tar.gz >> ${DISTNAME}-x86_64-linux-gnu.tar.gz.sha256sum
        else
            echo "${DISTNAME}-x86_64-linux-gnu.tar.gz doesn't exist. $?"
            exit 1
        fi
    else
        echo "release directory doesn't exist"
    fi
elif [[ ${OS} == "arm32v7" || ${OS} == "arm32v7-disable-wallet" ]]; then

    make install DESTDIR=${STAGE_DIR}/${DISTNAME}

    cd ${STAGE_DIR}
    find . -name "lib*.la" -delete
    find . -name "lib*.a" -delete
    rm -rf ${DISTNAME}/lib/pkgconfig
    if [[ -e ${STAGE_DIR}/${DISTNAME}/bin ]]; then
        find ${DISTNAME}/bin -type f -executable -exec ${WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    else
        echo "${STAGE_DIR}/${DISTNAME}/bin doesn't exist. $?"
    fi
    if [[ -e ${STAGE_DIR}/${DISTNAME}/lib ]]; then
        find ${DISTNAME}/lib -type f -exec ${WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    else
        echo "${STAGE_DIR}/${DISTNAME}/lib doesn't exist. $?"
    fi

    if [[ -e ${RELEASE_LOCATION} ]]; then
        cd ${STAGE_DIR}
        find ${DISTNAME}/ -not -name "*.dbg" | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > ${RELEASE_LOCATION}/${DISTNAME}-arm-linux-gnueabihf.tar.gz
        if [[ -e ${RELEASE_LOCATION}/${DISTNAME}-arm-linux-gnueabihf.tar.gz ]]; then
            cd ${RELEASE_LOCATION}
            md5sum ${DISTNAME}-arm-linux-gnueabihf.tar.gz >> ${DISTNAME}-arm-linux-gnueabihf.tar.gz.md5sum
            sha256sum ${DISTNAME}-arm-linux-gnueabihf.tar.gz >> ${DISTNAME}-arm-linux-gnueabihf.tar.gz.sha256sum
        else
            echo "${DISTNAME}-arm-linux-gnueabihf.tar.gz doesn't exist. $?"
            exit 1
        fi
        cd ${STAGE_DIR}
        cp -Rf ${DISTNAME}/bin/cmusicaid .
        cp -Rf ${DISTNAME}/bin/cmusicai-cli .
    else
        echo "release directory doesn't exist"
    fi
elif [[ ${OS} == "aarch64" || ${OS} == "aarch64-disable-wallet" ]]; then

    make install DESTDIR=${STAGE_DIR}/${DISTNAME}

    cd ${STAGE_DIR}
    find . -name "lib*.la" -delete
    find . -name "lib*.a" -delete
    rm -rf ${DISTNAME}/lib/pkgconfig
    if [[ -e ${STAGE_DIR}/${DISTNAME}/bin ]]; then
        find ${DISTNAME}/bin -type f -executable -exec ${WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    else
        echo "${STAGE_DIR}/${DISTNAME}/bin doesn't exist. $?"
    fi
    if [[ -e ${STAGE_DIR}/${DISTNAME}/lib ]]; then
        find ${DISTNAME}/lib -type f -exec ${WORKSPACE}/contrib/devtools/split-debug.sh {} {} {}.dbg \;
    else
        echo "${STAGE_DIR}/${DISTNAME}/lib doesn't exist. $?"
    fi

    if [[ -e ${RELEASE_LOCATION} ]]; then
        cd ${STAGE_DIR}
        find ${DISTNAME}/ -not -name "*.dbg" | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > ${RELEASE_LOCATION}/${DISTNAME}-aarch64-linux-gnu.tar.gz
        if [[ -e ${RELEASE_LOCATION}/${DISTNAME}-aarch64-linux-gnu.tar.gz ]]; then
            cd ${RELEASE_LOCATION}
            md5sum ${DISTNAME}-aarch64-linux-gnu.tar.gz >> ${DISTNAME}-aarch64-linux-gnu.tar.gz.md5sum
            sha256sum ${DISTNAME}-aarch64-linux-gnu.tar.gz >> ${DISTNAME}-aarch64-linux-gnu.tar.gz.sha256sum
        else
            echo "${DISTNAME}-aarch64-linux-gnu.tar.gz doesn't exist. $?"
            exit 1
        fi
        cd ${STAGE_DIR}
        cp -Rf ${DISTNAME}/bin/cmusicaid .
        cp -Rf ${DISTNAME}/bin/cmusicai-cli .
    else
        echo "release directory doesn't exist"
    fi
else
    echo "You must pass an OS."
    echo "Usage: ${0} <operating system> <github workspace path> <github base ref>"
    exit 1
fi