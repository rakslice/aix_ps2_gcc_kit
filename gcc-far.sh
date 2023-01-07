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

export PREFIX="$PREFIX/../far"

../gcc-2.7.2.3/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ \
--with-sysroot="$PREFIX/sysroot" --host=$TARGET --with-headers


echo far configure done
read

# when the script was just sitting there on the rh5 machine it had this exit here...
# is this a failed experiment or what
#exit
#make all-gcc
#make all-target-libgcc
#make install-gcc
#make install-target-libgcc
make LANGUAGES=c CC=i386-ibm-aix-gcc HOST_CC=gcc HOST_PREFIX=../build-gcc.1/ HOST_ALLOCA= HOST_CLIB=
echo far make done
read

make LANGUAGES=c install CC=i386-ibm-aix-gcc HOST_CC=gcc HOST_PREFIX=../build-gcc.1/ HOST_ALLOCA= HOST_CLIB=
echo far install done
read

