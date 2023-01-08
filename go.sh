#!/bin/bash
set -e

function dl() {
	[ $# -ge 1 ]
	url="$1"
	filename="$(basename "$1")"
	if [ ! -f "$filename" ]; then
		curl -LO "$1"
	fi
	hash="$(sha512sum "$filename" | cut -d' ' -f1)"
	[ "$hash" == "$2" ]
}

function need() {
	[ $# -eq 1 ]
	[ ! -f "$1.done" ]
}

function have() {
	[ $# -eq 1 ]
	touch "$1.done"
}

set -x

source_url="http://192.168.2.158:8122/source/open%20source/"

dl "$source_url/binutils-2.9.1.tar.gz" af9718100fec5cd0588fe7351952be1895c351b7262b4e913c920d41bf816b4dfe1ddccc4aac2831bcdfe6f005751f0045b6766181403b2f95ea82b246e8b15c

tar xf binutils-2.9.1.tar.gz

patch -p1 -i binutils-2.9.1-changes.patch


dl "$source_url/gcc-2.7.2.3.tar.gz" 9e685f4cb10239387da6c253710e79e011b82288d49acda5ab9b8318e9bb553d05008a8dc15a14e44d6aa8346f3e941460082aedea3b927b632daee78f823209

tar xf gcc-2.7.2.3.tar.gz

patch -p1 -i gcc-2.7.2.3-changes.patch

# things from the aix machine we need

exports_url="$source_url/aix%20gcc%20build"

# - built libgcc1.a
dl "$exports_url/libgcc1.a" 0ca75ed5ce29b741da91265cdf01fd3aa97617deebb7e67b3497ced71512e13db1265d2c80cf6f9827d55778dab689847a6484641806c58d1bc4a3b1940bd097
# - includes
dl "$exports_url/aixinclude.dsk" cff38252ac668b321aa7d3098485a7f1d5c577d9f220b9eaf76c50db6580728373d578e6705c09e126990ea440fd64a7ff41c29ab1569a076b7dce48be9027a8
# - libs
dl "$exports_url/aixbaselib.dsk" 42a86eaeafd4afe27688b11722d03dadcef8bd300eef7a57216c97e955e42b32f2a4f0f7489732a4d5021b4990a3450f82700c434049ed831cf68d650294ff72
dl "$exports_url/aixlib1.dsk" 4dfdbcc8dea7eb830d964e1203c961f20bd355725035fee2da8854369da55232ff7c5af9074a68700560a8c6167021f348fcc60b3f1f701d2d3691e58b724980
dl "$exports_url/aixlib2.dsk" 8eb1a56c2f5174b8618bcf3eeec8ae42b8febe3297baeb7576355a4eae0ff51720180bc961e133eddd2f7f84936b89b3cd502e04e206d73b248df1d2affd396e


cat aixinclude.dsk > aixinclude.tar.gz
gunzip -f aixinclude.tar.gz || true

cat aixbaselib.dsk > aixbaselib.tar.gz
gunzip -f aixbaselib.tar.gz || true

cat aixlib1.dsk aixlib2.dsk > aixlib.tar.gz
gunzip -f aixlib.tar.gz || true

mkdir -p sysroot
pushd sysroot
tar xf ../aixbaselib.tar
tar xf ../aixlib.tar
popd

mkdir -p aixinclude
pushd aixinclude
tar xf ../aixinclude.tar
cd usr
patch -p2 -i ../../includes.patch
popd

sudo ./create_chroot.sh "$@"

# pack the disk images
tar czf crossnative.tar.gz build-gcc

split -b 1440k crossnative.tar.gz crossnative.dsk.

[ -f crossnative.dsk.ac ]
[ ! -f crossnative.dsk.ad ]

mv crossnative.dsk.aa crossnative1.dsk
mv crossnative.dsk.ab crossnative2.dsk
mv crossnative.dsk.ac crossnative3.dsk
