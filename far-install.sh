#!/bin/sh

set -e
set -x

gcc=/opt/gcc-$GCC_VER

if [ -d gcc ]; then
  cd gcc
fi

if [ ! -d $gcc ]; then
  mkdir $gcc
fi

if [ ! -d $gcc/bin ]; then
  mkdir $gcc/bin
fi

cp xgcc $gcc/bin/gcc
cp cc1 cpp g++ cccp $gcc/bin

if [ ! -d $gcc/lib ]; then
  mkdir $gcc/lib
fi

cp libgcc.a $gcc/lib

