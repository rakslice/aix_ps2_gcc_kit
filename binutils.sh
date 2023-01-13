#!/bin/bash

# Build a set of binutils that will run on HOST for doing stuff with binaries for TARGET
# (that is to say, cross binutils for TARGET that we can use here)

set -e -x
mkdir build-binutils
cd build-binutils
../binutils-2.9.1/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror --host="$HOST"
make $@
make install 

cd ..
mv build-binutils build-binutils.1
