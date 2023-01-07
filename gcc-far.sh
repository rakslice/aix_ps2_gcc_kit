#!/bin/bash
set -e -x

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which -- $TARGET-as || echo $TARGET-as is not in the PATH

if [ -d build-gcc ]; then
	rm -rf build-gcc
fi
 
mkdir build-gcc
cd build-gcc

cp ../natives/* .

export PREFIX="$PREFIX/../far"

../gcc-2.7.2.3/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --with-sysroot="$PREFIX/sysroot" --host=$TARGET --with-headers
exit
#make all-gcc
#make all-target-libgcc
#make install-gcc
#make install-target-libgcc
make LANGUAGES=c CC=i386-ibm-aix-gcc HOST_CC=gcc HOST_PREFIX=../build-gcc.1/ HOST_ALLOCA= HOST_CLIB=
make LANGUAGES=c install CC=i386-ibm-aix-gcc HOST_CC=gcc HOST_PREFIX=../build-gcc.1/ HOST_ALLOCA= HOST_CLIB=

