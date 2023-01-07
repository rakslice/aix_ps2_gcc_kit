#!/bin/bash
set -e -x

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which $TARGET-as

if [ -d build-gcc ]; then
	rm -rf build-gcc
fi
 
mkdir build-gcc
cd build-gcc

cp ../libgcc1.a .

#OLD_PREFIX="$PREFIX"

export PREFIX="$PREFIX/../far"

../gcc-2.7.2.3/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ \
--with-sysroot="$PREFIX/sysroot" --host=$TARGET --with-headers --build=i486-unknown-linux

#make all-gcc
#make all-target-libgcc
#make install-gcc
#make install-target-libgcc
args="LANGUAGES=c GCC_FOR_TARGET=i386-ibm-aix-gcc CC=i386-ibm-aix-gcc HOST_CC=gcc HOST_ALLOCA= HOST_CLIB= HOST_PREFIX=../build-gcc.1/ "
make $args "$@"
make $args install

