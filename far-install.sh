#!/bin/sh

set -e -x

gcc=/opt/gcc-2.7.2.3

if [ ! -d $gcc/bin ]; then
  mkdir -p $gcc/bin
fi

cp xgcc $gcc/bin/gcc
cp cc1 cpp g++ cccp $gcc/bin

if [ ! -d $gcc/lib ]; then
  mkdir -p $gcc/lib
fi

cp libgcc1.a $gcc/lib

