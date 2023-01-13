#!/bin/bash
set -e -x

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which $TARGET-as

if [ ! -d build-gcc ]; then mkdir build-gcc; fi
cd build-gcc

if [ "$GCC_VER" = "2.95.3" ]; then
  # for newer gcc
  if [ ! -d gcc ]; then mkdir gcc; fi
  cp ../libgcc1.a gcc/libgcc1.a
else
  # for older gcc
  cp ../libgcc1.a .
fi

if [ ! -f .configure.done ]; then

../gcc-$GCC_VER/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ \
  --with-sysroot="$PREFIX/sysroot" --host="$HOST" --with-headers
touch .configure.done

fi

make LANGUAGES=c "$@"
make LANGUAGES=c install

cd ..
mv build-gcc build-gcc.1
