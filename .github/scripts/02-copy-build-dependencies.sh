#!/usr/bin/env bash

OS=${1}
GITHUB_WORKSPACE=${2}
GITHUB_REF=${3}

if [[ ! ${OS} || ! ${GITHUB_WORKSPACE} ]]; then
    echo "Error: Invalid options"
    echo "Usage: ${0} <operating system> <github workspace path>"
    exit 1
fi

echo "----------------------------------------"
echo "OS: ${OS}"
echo "----------------------------------------"

if [[ ${OS} == "arm32v7-disable-wallet" || ${OS} == "linux-disable-wallet" || ${OS} == "aarch64-disable-wallet" ]]; then
    OS=$(echo ${OS} | cut -d"-" -f1)
fi

echo "----------------------------------------"
echo "Building Dependencies for ${OS}"
echo "----------------------------------------"

cd depends
if [[ ${OS} == "windows" ]]; then
    make HOST=x86_64-w64-mingw32 -j2
elif [[ ${OS} == "osx" ]]; then
    mkdir -p SDKs
    cd SDKs
    curl -O https://bitcoincore.org/depends-sources/sdks/Xcode-11.3.1-11C505-extracted-SDK-with-libcxx-headers.tar.gz
    tar -zxf Xcode-11.3.1-11C505-extracted-SDK-with-libcxx-headers.tar.gz
    rm -rf Xcode-11.3.1-11C505-extracted-SDK-with-libcxx-headers.tar.gz
    cd ..
    chmod +x contrib/install_db4.sh
    ./contrib/install_db4.sh $(pwd)

    export BDB_PREFIX=${GITHUB_WORKSPACE}/db4
    export BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8"
    export BDB_CFLAGS="-I${BDB_PREFIX}/include"
    export BOOST_ROOT=/usr/include/boost
    export BOOST_LIB_PATH=/usr/lib/x86_64-linux-gnu

    CONFIG_SITE=${GITHUB_WORKSPACE}/depends/x86_64-apple-darwin14/share/config.site \
    ./configure --prefix=/ --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-reduce-exports --disable-bench --with-gui=qt5 --with-boost=${BOOST_ROOT} --with-boost-libdir=${BOOST_LIB_PATH} GENISOIMAGE=${GITHUB_WORKSPACE}/depends/x86_64-apple-darwin14/native/bin/genisoimage BDB_LIBS="${BDB_LIBS}" BDB_CFLAGS="${BDB_CFLAGS}"

    make HOST=x86_64-apple-darwin14 -j2
elif [[ ${OS} == "linux" || ${OS} == "linux-disable-wallet" ]]; then
    make HOST=x86_64-linux-gnu -j2
elif [[ ${OS} == "arm32v7" || ${OS} == "arm32v7-disable-wallet" ]]; then
    make HOST=arm-linux-gnueabihf -j2
elif [[ ${OS} == "aarch64" || ${OS} == "aarch64-disable-wallet" ]]; then
    make HOST=aarch64-linux-gnu -j2
fi
