#!/bin/bash
set -e -x

[ $# -eq 1 ]

GCC_VER="$1"

[ "$GCC_VER" != "" ]

if [ -d sysroot_headers ]; then
  rm -rf sysroot_headers
fi
mkdir sysroot_headers

cp -a aixinclude/usr/include sysroot_headers
cp -a /tmp/rh5_chroot/root/opt/cross/lib/gcc-lib/i386-ibm-aix/$GCC_VER/include sysroot_headers

rm sysroot_headers/include/float.h

output=sysroot_headers-$GCC_VER.tar.gz

if [ -f "$output" ]; then
	rm "$output"
fi
tar czf "$output" sysroot_headers
