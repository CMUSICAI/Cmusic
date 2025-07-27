#!/usr/bin/env bash
set -e

cd /cmusic

# Build dependencies for all targets
cd depends
make HOST=x86_64-linux-gnu -j$(nproc)
make HOST=arm-linux-gnueabihf -j$(nproc)
make HOST=aarch64-linux-gnu -j$(nproc)
make HOST=x86_64-w64-mingw32 -j$(nproc)
cd ..

./autogen.sh

build_target() {
  TARGET=$1
  HOST=$2
  EXTRA="$3"
  mkdir build-$TARGET
  cd build-$TARGET
  CONFIG_SITE=../depends/$HOST/share/config.site \
  ../configure --prefix=/ --disable-ccache --disable-maintainer-mode \
    --disable-dependency-tracking --enable-glibc-back-compat --enable-reduce-exports \
    --disable-bench --disable-gui-tests CFLAGS="-O2 -g" CXXFLAGS="-O2 -g" \
    LDFLAGS="-static-libstdc++" $EXTRA
  make -j$(nproc)
  cd ..
}

# Linux builds
build_target linux x86_64-linux-gnu ""
build_target linux-disable-wallet x86_64-linux-gnu "--disable-wallet"

# ARM 32-bit builds
build_target arm32v7 arm-linux-gnueabihf ""
build_target arm32v7-disable-wallet arm-linux-gnueabihf "--disable-wallet"

# AArch64 builds
build_target aarch64 aarch64-linux-gnu ""
build_target aarch64-disable-wallet aarch64-linux-gnu "--disable-wallet"

# Windows build
echo "Building windows..."
mkdir build-windows
cd build-windows
CONFIG_SITE=../depends/x86_64-w64-mingw32/share/config.site \
  ../configure --prefix=/ --disable-ccache --disable-maintainer-mode \
  --disable-dependency-tracking --enable-reduce-exports --disable-bench \
  --disable-tests --disable-gui-tests --enable-shared=no CFLAGS="-O2 -g" CXXFLAGS="-O2 -g"
make -j$(nproc)
cd ..

# Package builds
mkdir -p /cmusic/built

package_unix() {
  TARGET=$1
  cd build-$TARGET
  strip src/cmusicaid src/cmusicai-cli || true
  if [ -f src/qt/cmusicai-qt ]; then strip src/qt/cmusicai-qt; fi
  zip -j /cmusic/built/${TARGET}.zip src/cmusicaid src/cmusicai-cli src/qt/cmusicai-qt 2>/dev/null || \
  zip -j /cmusic/built/${TARGET}.zip src/cmusicaid src/cmusicai-cli
  cd ..
}

package_unix linux
package_unix linux-disable-wallet
package_unix arm32v7
package_unix arm32v7-disable-wallet
package_unix aarch64
package_unix aarch64-disable-wallet

cd build-windows
/usr/bin/x86_64-w64-mingw32-strip src/cmusicaid.exe src/cmusicai-cli.exe || true
if [ -f src/qt/cmusicai-qt.exe ]; then /usr/bin/x86_64-w64-mingw32-strip src/qt/cmusicai-qt.exe; fi
zip -j /cmusic/built/windows.zip src/cmusicaid.exe src/cmusicai-cli.exe src/qt/cmusicai-qt.exe 2>/dev/null || \
zip -j /cmusic/built/windows.zip src/cmusicaid.exe src/cmusicai-cli.exe
cd ..