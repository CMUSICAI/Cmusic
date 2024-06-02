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

set -e  # Exit immediately if a command exits with a non-zero status
set -x  # Print commands and their arguments as they are executed

if [[ ${OS} == "windows" ]]; then
    sudo apt-get update
    sudo apt-get install -y \
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

    sudo update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

elif [[ ${OS} == "osx" ]]; then
    sudo apt-get update
    sudo apt-get install -y \
    automake \
    autotools-dev \
    bsdmainutils \
    build-essential \
    curl \
    clang \
    llvm \
    git \
    libtool \
    pkg-config \
    python3 \
    rename \
    zip \
    bison \
    cmake \
    mingw-w64 \
    binutils-mingw-w64 \
    gcc-mingw-w64 \
    g++-mingw-w64

    # Install SDKs and Toolchain in depends/SDKs
    mkdir -p depends/SDKs
    cd depends/SDKs
    wget https://bitcoincore.org/depends-sources/sdks/Xcode-11.3.1-11C505-extracted-SDK-with-libcxx-headers.tar.gz
    tar -zxf Xcode-11.3.1-11C505-extracted-SDK-with-libcxx-headers.tar.gz
    cd -

    # Install osxcross for cross-compiling macOS binaries
    if [ ! -d "/opt/osxcross" ]; then
        git clone https://github.com/tpoechtrager/osxcross.git /opt/osxcross
        cd /opt/osxcross
        mv ../depends/SDKs/MacOSX10.15.sdk tarballs/
        UNATTENDED=yes ./build.sh
        cd -
    fi

    export PATH="/opt/osxcross/target/bin:$PATH"
    export OSXCROSS_MP_INC=1

elif [[ ${OS} == "linux" || ${OS} == "linux-disable-wallet" || ${OS} == "aarch64" || ${OS} == "aarch64-disable-wallet" ]]; then
    sudo apt-get update
    sudo apt-get install -y \
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
    sudo apt-get update
    sudo apt-get install -y \
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
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 2
fi

# Verify installation and compiler versions
echo "----------------------------------------"
echo "Verifying installation and compiler versions"
echo "----------------------------------------"
gcc --version || clang --version
g++ --version || clang++ --version
autoconf --version
automake --version
libtool --version || echo "libtool is not installed"
pkg-config --version

# Capture config.log if configure fails
trap 'if [ -f "config.log" ];then cat config.log;fi' ERR
