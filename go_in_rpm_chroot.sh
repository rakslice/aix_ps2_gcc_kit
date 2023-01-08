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

cd /home/user/src/aix_toolchain_new

export PREFIX="$HOME/opt/cross"
export TARGET=i386-ibm-aix
export PATH="$PREFIX/bin:$PATH"
export HOST="i486-unknown-linux"

if need binutils-near; then

  # copy the sysroot into place
  mkdir -p $PREFIX
  cp -avf sysroot $PREFIX
  # copy the includes into the target-name dir
  mkdir -p $PREFIX/$TARGET
  cp -avf aixinclude/usr/include $PREFIX/$TARGET
  # copy all the libs into the target-name dir
  cp -avf $PREFIX/sysroot/lib $PREFIX/$TARGET
  cp -avf $PREFIX/sysroot/usr/lib $PREFIX/$TARGET

  ./binutils.sh $common_make_args

  have binutils-near

fi

if need gcc-near; then

  ./gcc.sh $common_make_args

  cat gcc-lib-include.patch | patch -p0 -d $PREFIX/lib/gcc-lib/i386-ibm-aix/2.7.2.3

  have gcc-near

fi

if need gcc-far-2; then

  ./gcc-far-2.sh $common_make_args

  have gcc-far-2

fi
