#!/usr/bin/env bash

OS=${1}

if [[ ! ${OS} ]]; then
    echo "Error: Invalid options"
    echo "Usage: ${0} <operating system>"
    exit 1
fi

echo "----------------------------------------"
echo "Installing Build Packages for ${OS}"
echo "----------------------------------------"

if [[ ${OS} == "windows" ]]; then
    apt-get update
    apt-get install -y \
    automake \
    autotools-dev \
    bsdmainutils \
    build-essential \
    curl \
    mingw-w64 \
    mingw-w64-x86-64-dev \
    git \
    libcurl4-openssl-dev \
    libssl-dev \
    libtool \
    osslsigncode \
    nsis \
    pkg-config \
    python3 \
    rename \
    zip \
    bison

    update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

elif [[ ${OS} == "osx" ]]; then
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl g++ git pkg-config autoconf librsvg2-bin libtiff-tools libtool automake bsdmainutils cmake imagemagick libcap-dev libz-dev libbz2-dev python python-dev python-setuptools fonts-tuffy \
                            clang qtbase5-dev qttools5-dev-tools qtdeclarative5-dev libboost-all-dev libminiupnpc-dev protobuf-compiler libprotobuf-dev inkscape

    pip3 install ds-store

elif [[ ${OS} == "linux" || ${OS} == "linux-disable-wallet" || ${OS} == "aarch64" || ${OS} == "aarch64-disable-wallet" ]]; then
    apt-get update
    apt-get install -y \
    apt-file \
    autoconf \
    automake \
    autotools-dev \
    binutils-aarch64-linux-gnu \
    binutils \
    bsdmainutils \
    build-essential \
    ca-certificates \
    curl \
    g++-aarch64-linux-gnu \
    g++-9-aarch64-linux-gnu \
    g++-9-multilib \
    gcc-9-aarch64-linux-gnu \
    gcc-9-multilib \
    git \
    gnupg \
    libtool \
    nsis \
    pbuilder \
    pkg-config \
    python3 \
    rename \
    ubuntu-dev-tools \
    xkb-data \
    zip \
    bison

elif [[ ${OS} == "arm32v7" || ${OS} == "arm32v7-disable-wallet" ]]; then
    apt-get update
    apt-get install -y \
    autoconf \
    automake \
    binutils-aarch64-linux-gnu \
    binutils-arm-linux-gnueabihf \
    binutils \
    bsdmainutils \
    ca-certificates \
    curl \
    g++-aarch64-linux-gnu \
    g++-9-aarch64-linux-gnu \
    gcc-9-aarch64-linux-gnu \
    g++-arm-linux-gnueabihf \
    g++-9-arm-linux-gnueabihf \
    gcc-9-arm-linux-gnueabihf \
    g++-9-multilib \
    gcc-9-multilib \
    git \
    libtool \
    pkg-config \
    python3 \
    bison
else
    echo "you must pass the OS to build for"
    exit 1
fi

if [[ ${OS} != "osx" ]]; then
    update-alternatives --install /usr/bin/python python /usr/bin/python2 1
    update-alternatives --install /usr/bin/python python /usr/bin/python3 2
fi
