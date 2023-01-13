#!/bin/bash
set -e -x

# Build a compiler here that compiles code to run on TARGET and itself runs on TARGET 
# (that is, a native compiler for TARGET rather than HOST)

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which $TARGET-as

# For newer gcc than the stock one in chroot, the stock makeinfo is also not new enough to build its docs.
# GCC contains the code for it so it can build it if it needs it normally, but it stupidly
# doesn't build it for the build machine, where it is about to need to use makeinfo to build docs.
# Just use the one we have from the cross-compiler build that was built for HOST.
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

