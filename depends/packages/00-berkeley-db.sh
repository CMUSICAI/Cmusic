# 00-berkeley-db.sh
#!/usr/bin/env bash

OS=${1}

if [[ ${OS} == "osx" ]]; then
    echo "Installing Berkeley DB for macOS"
    mkdir -p depends/SDKs
    cd depends/SDKs
    curl -O http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
    tar -zxvf db-4.8.30.NC.tar.gz
    cd db-4.8.30.NC/build_unix
    ../dist/configure --prefix=$PWD/../..
    make -j$(nproc)
    make install
else
    echo "Skipping Berkeley DB installation for ${OS}"
fi
