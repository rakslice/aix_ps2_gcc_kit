#!/bin/bash
set -e -x

tar=../aixinclude.tar
patch=../includes.patch

[ -f "$tar" ]
[ -f "$patch" ]

tar="$(realpath "$tar")"
patch="$(realpath "$patch")"

mkdir orig
mkdir mod

pushd orig

tar xf "$tar"

cd ../mod

tar xf "$tar"
patch -p1 -i "$patch"

popd


