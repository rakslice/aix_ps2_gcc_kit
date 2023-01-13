#!/bin/bash
set -e

function need() {
	[ $# -eq 1 ]
	[ ! -f "$1.done" ]
}

function have() {
	[ $# -eq 1 ]
	touch "$1.done"
}

#common_make_args=" "
common_make_args="-j4"

set -x

[ $# -eq 2 ]

GCC_VER="$1"
export GCC_VER

username="$2"

cd /home/$username/src/aix_toolchain_new

export PREFIX="$HOME/opt/cross"
export TARGET=i386-ibm-aix
export PATH="$PREFIX/bin:$PATH"
export HOST="i486-unknown-linux"

#if [ "$GCC_VER" != "2.7.2.3" ]; then

  # let's begin with our local gcc

#  if need gcc-native; then
#
#    ./gcc-native.sh $common_make_args
#
#    have gcc-native
#
#  fi

#fi

if need binutils-near; then

  # copy the sysroot into place
  mkdir -p $PREFIX
  cp -avf sysroot $PREFIX/

  # copy the includes into the target-name dir
  mkdir -p $PREFIX/$TARGET
  if [ "$GCC_VER" = "2.95.3" ]; then
    if [ -d $PREFIX/$TARGET/sys-include ]; then rm -rf $PREFIX/$TARGET/sys-include; fi
    cp -af aixinclude/usr/include $PREFIX/$TARGET/sys-include
  else
    cp -af aixinclude/usr/include $PREFIX/$TARGET/
  fi
  # copy all the libs into the target-name dir
  cp -avf $PREFIX/sysroot/lib $PREFIX/$TARGET/
  cp -avf $PREFIX/sysroot/usr/lib $PREFIX/$TARGET/



  ./binutils.sh $common_make_args

  have binutils-near

fi

if need gcc-near; then

  ./gcc.sh $common_make_args

  #cat gcc-lib-include.patch | patch -p1 -d $PREFIX/lib/gcc-lib/i386-ibm-aix/2.7.2.3
  #cat gcc-lib-include.patch | patch -p1 -d $PREFIX/i386-ibm-aix
  #cat gcc-lib-include.patch | patch -p1 -d $PREFIX/lib/gcc-lib/i386-ibm-aix/$GCC_VER

  have gcc-near

fi

export PREFIX="$HOME/opt/far"

if need gcc-far-2; then

  # copy the sysroot into place
  mkdir -p $PREFIX
  cp -avf sysroot $PREFIX/

  ./gcc-far-2.sh $common_make_args

  have gcc-far-2

fi

export PREFIX="$HOME/opt/cross-far"

if need binutils-far; then
  ./binutils-far.sh $common_make_args

  have binutils-far
fi
