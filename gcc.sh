#!/bin/bash
set -e -x

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which $TARGET-as
 
mkdir build-gcc
cd build-gcc

cp ../libgcc1.a .

../gcc-2.7.2.3/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ \
--with-sysroot="$PREFIX/sysroot" --host=i486-unknown-linux --with-headers
make LANGUAGES=c "$@"
make LANGUAGES=c install

cd ..
mv build-gcc build-gcc.1
