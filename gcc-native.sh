#!/bin/bash
set -e -x

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which $TARGET-as
 
mkdir build-gcc
cd build-gcc
#../gcc-2.6.3/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
#../gcc-2.6.3/configure --target=$TARGET --prefix="$PREFIX" --enable-languages=c,c++ --without-headers --host=i486-unknown-linux
../gcc-2.7.2.3/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --host=i486-unknown-linux
#make all-gcc
#make all-target-libgcc
#make install-gcc
#make install-target-libgcc
make LANGUAGES=c
make LANGUAGES=c install

