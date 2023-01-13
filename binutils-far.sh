#!/bin/bash
set -e -x

# Build a set of binutils that run on TARGET for doing stuff with TARGET binaries
# (that is to say, native binutils for TARGET rather than for this machine)

if [ -d build-binutils ]; then
	rm -rf build-binutils
fi

mkdir build-binutils
cd build-binutils

../binutils-2.9.1/configure --build="$HOST" --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror --host=$TARGET
make
make install

