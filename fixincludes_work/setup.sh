#!/bin/bash
set -e -x

indir=../rh5_chroot/root/opt/cross/lib/gcc-lib/i386-ibm-aix/2.7.2.3/include
patch=../gcc-lib-include.patch

[ -d "$indir" ]
[ -f "$patch" ]

patch="$(realpath "$patch")"

mkdir orig
mkdir mod

cp -av "$indir" orig/
cp -av "$indir" mod/

#pushd mod
#patch -p0 -i "$patch"

pushd orig
patch -p1 -R -i "$patch"

popd


