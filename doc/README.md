CmusicAI Core
==============

Setup
---------------------
Cmusic Core is the original Cmusic client and it builds the backbone of the network. It downloads and, by default, stores the entire history of Cmusic transactions; depending on the speed of your computer and network connection, the synchronization process is typically complete in under an hour.

To download compiled binaries of the Cmusic Core and wallet, visit the [GitHub release page](https://github.com/CMUSICAI/Cmusic/releases).

Running
---------------------
The following are some helpful notes on how to run Cmusic on your native platform.

### Linux

1) Download and extract binaries to desired folder.

2) Install distribution-specific dependencies listed below.

3) Run the GUI wallet or only the Cmusic core deamon

   a. GUI wallet:

   `./cmusicai-qt`

   b. Core deamon:

   `./cmusicaid -deamon`

#### Ubuntu

Update apt cache and install general dependencies:

```bash
sudo apt update
sudo apt install libevent-dev libboost-all-dev libminiupnpc-dev libzmq5 software-properties-common
```

The wallet requires version 4.8 of the Berkeley DB. The easiest way to get it is to build it with the script `contrib/install_db4.sh`


The GUI wallet requires the QR Code encoding library. Install with:
```bash
sudo apt install libqrencode3
```

#### Fedora 27

Install general dependencies:
```bash
sudo dnf install zeromq libevent boost libdb4-cxx miniupnpc
```

The GUI wallet requires the QR Code encoding library and Google's data interchange format Protocol Buffers. Install with:
```bash
sudo dnf install qrencode protobuf
```

#### CentOS 7

Add the EPEL repository and install general depencencies:

```bash
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install zeromq libevent boost libdb4-cxx miniupnpc
```

The GUI wallet requires the QR Code encoding library and Google's data interchange format Protocol Buffers. Install with:
```bash
sudo yum install qrencode protobuf
```

### OS X

Coming soon.

### Windows

1) Download `windows-x86_64.zip` and unpack executables to desired folder.

2) Double click the `cmusicai-qt.exe` to launch it.

### Need Help?

- Ask for help on [Discord](https://discord.gg/EanhmGKxcg) or [Telegram](https://t.me/CmusicAI).

Building from source
---------------------
The following are developer notes on how to build the Cmusic core software on your native platform. They are not complete guides, but include notes on the necessary libraries, compile flags, etc.

- [Dependencies](https://github.com/CMUSICAI/Cmusic/tree/master/doc/dependencies.md)
- [OS X Build Notes](https://github.com/CMUSICAI/Cmusic/tree/master/doc/build-osx.md)
- [Unix Build Notes](https://github.com/CMUSICAI/Cmusic/tree/master/doc/build-unix.md)
- [Windows Build Notes](https://github.com/CMUSICAI/Cmusic/tree/master/doc/build-windows.md)
- [OpenBSD Build Notes](https://github.com/CMUSICAI/Cmusic/tree/master/doc/build-openbsd.md)
- [Gitian Building Guide](https://github.com/CMUSICAI/Cmusic/tree/master/doc/gitian-building.md)

Development
---------------------
Cmusic repo's [root README](https://github.com/CMUSICAI/Cmusic/blob/master/README.md) contains relevant information on the development process and automated testing.

- [Developer Notes](https://github.com/CMUSICAI/Cmusic/blob/master/doc/developer-notes.md)
- [Release Notes](https://github.com/CMUSICAI/Cmusic/blob/master/doc/release-notes.md)
- [Release Process](https://github.com/CMUSICAI/Cmusic/blob/master/doc/release-process.md)
- [Source Code Documentation (External Link)](https://dev.visucore.com/cmusicai/doxygen/) -- 2018-05-11 -- Broken link
- [Translation Process](https://github.com/CMUSICAI/Cmusic/blob/master/doc/translation_process.md)
- [Translation Strings Policy](https://github.com/CMUSICAI/Cmusic/blob/master/doc/translation_strings_policy.md)
- [Travis CI](https://github.com/CMUSICAI/Cmusic/blob/master/doc/travis-ci.md)
- [Unauthenticated REST Interface](https://github.com/CMUSICAI/Cmusic/blob/master/doc/REST-interface.md)
- [Shared Libraries](https://github.com/CMUSICAI/Cmusic/blob/master/doc/shared-libraries.md)
- [BIPS](https://github.com/CMUSICAI/Cmusic/blob/master/doc/bips.md)
- [Benchmarking](https://github.com/CMUSICAI/Cmusic/blob/master/doc/benchmarking.md)

### Resources
- Discuss on chat [Discord](https://discord.gg/EanhmGKxcg) or [Telegram](https://t.me/CmusicAI).
- Visit the project home [Cmusic.AI](https://cmusic.ai)

### Miscellaneous
- [Assets Attribution](https://github.com/CMUSICAI/Cmusic/blob/master/doc/assets-attribution.md)
- [Files](https://github.com/CMUSICAI/Cmusic/blob/master/doc/files.md)
- [Fuzz-testing](https://github.com/CMUSICAI/Cmusic/blob/master/doc/fuzzing.md)
- [Reduce Traffic](https://github.com/CMUSICAI/Cmusic/blob/master/doc/reduce-traffic.md)
- [Tor Support](https://github.com/CMUSICAI/Cmusic/blob/master/doc/tor.md)
- [Init Scripts (systemd/upstart/openrc)](https://github.com/CMUSICAI/Cmusic/blob/master/doc/init.md)
- [ZMQ](https://github.com/CMUSICAI/Cmusic/blob/master/doc/zmq.md)

License
---------------------
Distributed under the [MIT software license](https://github.com/CMUSICAI/Cmusic/blob/master/COPYING).
This product includes software developed by the OpenSSL Project for use in the [OpenSSL Toolkit](https://www.openssl.org/). This product includes
cryptographic software written by Eric Young ([eay@cryptsoft.com](mailto:eay@cryptsoft.com)), and UPnP software written by Thomas Bernard.
