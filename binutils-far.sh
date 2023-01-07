#!/bin/bash
set -e -x

if [ -d build-binutils ]; then
	rm -rf build-binutils
fi

mkdir build-binutils
cd build-binutils
#../binutils-2.7/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror --host="i486-box-linux"
#../binutils-2.7/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror 
#../binutils-2.9.1/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror 

export PREFIX=${PREFIX}-far
../binutils-2.9.1/configure --build="i486-box-linux" --target=$TARGET --host=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror 
make
make install

