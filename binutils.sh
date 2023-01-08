#!/bin/bash
set -e -x
mkdir build-binutils
cd build-binutils
HOST=i486-unknown-linux
../binutils-2.9.1/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror --host="$HOST"
make $@
make install 

cd ..
mv build-binutils build-binutils.1
