#!/usr/bin/env bash

OS=${1}

if [[ ${OS} == "osx" ]]; then
    echo "Installing Berkeley DB for macOS"
    mkdir -p depends/SDKs
    cd depends/SDKs
    curl -L --retry 5 --retry-delay 5 --connect-timeout 10 --max-time 300 -O http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
    if [ $? -ne 0 ]; then
        echo "Error downloading Berkeley DB"
        exit 1
    fi
    tar -zxvf db-4.8.30.NC.tar.gz
    if [ $? -ne 0 ]; then
        echo "Error extracting Berkeley DB"
        exit 1
    fi
    cd db-4.8.30.NC/build_unix
    ../dist/configure --prefix=$PWD/../..
    if [ $? -ne 0 ]; then
        echo "Error configuring Berkeley DB"
        exit 1
    fi
    make -j$(nproc)
    if [ $? -ne 0 ]; then
        echo "Error building Berkeley DB"
        exit 1
    fi
    make install
    if [ $? -ne 0 ]; then
        echo "Error installing Berkeley DB"
        exit 1
    fi
else
    echo "Skipping Berkeley DB installation for ${OS}"
fi
