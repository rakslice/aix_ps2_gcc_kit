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

set -x

cd /home/user/src/aix_toolchain_new

export PREFIX="$HOME/opt/cross"
export TARGET=i386-ibm-aix
export PATH="$PREFIX/bin:$PATH"
export HOST="i386-redhat-linux"

if need binutils-near; then

#tar xf gcc-2.7.2.3

  ./binutils.sh -j4

  have binutils-near

fi

if need gcc-near; then

  cp -avf aixinclude/usr/include $PREFIX/$TARGET
  cp -avf aixlib/usr/lib $PREFIX/$TARGET

  #bash

  ./gcc.sh -j4

  have gcc-near
fi
