#!/bin/bash
set -e -x

if [ -d build-binutils ]; then
	rm -rf build-binutils
fi

mkdir build-binutils
cd build-binutils

../binutils-2.9.1/configure --build="$HOST" --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror --host=$TARGET
make
make install

