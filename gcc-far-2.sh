#!/bin/bash
set -e -x

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which $TARGET-as

our_makeinfo="$(pwd)/build-gcc.1/texinfo/makeinfo/makeinfo"

if [ ! -d build-gcc ]; then
  mkdir build-gcc
fi
cd build-gcc

cp ../libgcc1.a .

if [ "$GCC_VER" = "2.95.3" ]; then
  gcc_subdir="gcc"
else
  gcc_subdir="."
fi

if [ ! -f .configure.done ]; then

../gcc-$GCC_VER-far/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ \
--with-sysroot="$PREFIX/sysroot" --host=$TARGET --build="$HOST"

touch .configure.done

fi

#--with-sysroot="$PREFIX/sysroot" --host=$TARGET --with-headers --build="$HOST"


args="LANGUAGES=c GCC_FOR_TARGET=i386-ibm-aix-gcc CC=i386-ibm-aix-gcc HOST_CC=gcc HOST_ALLOCA= HOST_CLIB= MAKEINFO=$our_makeinfo"
make $args "$@"
make -C "$gcc_subdir" $args libgcc.a "$@"
make $args install

cp ../far-install.sh .

