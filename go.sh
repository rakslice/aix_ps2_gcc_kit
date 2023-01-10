#!/bin/bash
set -e

function cs() {
	[ $# -ge 1 ]
	filename="$1"
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

function pad_file() {
	[ $# -eq 2 ]
	file="$1"
	target_size=$2
	cur_size=$(stat -c "%s" "$file")
	if [ $cur_size -lt $target_size ]; then
		pad_size=$(( $target_size - $cur_size ))
		dd if=/dev/zero bs=1 count=$pad_size | cat "$file" - > "$file.padded"
		mv "$file.padded" "$file"
	fi
}

set -x

cs binutils-2.9.1.tar.gz af9718100fec5cd0588fe7351952be1895c351b7262b4e913c920d41bf816b4dfe1ddccc4aac2831bcdfe6f005751f0045b6766181403b2f95ea82b246e8b15c

tar xf binutils-2.9.1.tar.gz

patch -p1 -i binutils-2.9.1-changes.patch


cs gcc-2.7.2.3.tar.gz 9e685f4cb10239387da6c253710e79e011b82288d49acda5ab9b8318e9bb553d05008a8dc15a14e44d6aa8346f3e941460082aedea3b927b632daee78f823209

tar xf gcc-2.7.2.3.tar.gz

patch -p1 -i gcc-2.7.2.3-changes.patch

# things from the aix machine we need

# - built libgcc1.a

[ -f libgcc1.a ]

# - includes

[ -f aixinclude.dsk ]

# - libs

[ -f aixbaselib.dsk ]
[ -f aixlib1.dsk ]
[ -f aixlib2.dsk ]


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

# This will prepare the chroot and run the go_in_rpm_chroot.sh script inside to do the build
sudo ./create_chroot.sh "$@"

# pack the disk images
tar czf crossnative.tar.gz build-gcc

split -b 1440k crossnative.tar.gz crossnative.dsk.

# expect 3 parts
[ -f crossnative.dsk.ac ]
[ ! -f crossnative.dsk.ad ]

mv crossnative.dsk.aa crossnative1.dsk
mv crossnative.dsk.ab crossnative2.dsk
mv crossnative.dsk.ac crossnative3.dsk
pad_file crossnative3.dsk 1474560

tar czf binutils.tar.gz rh5_chroot/root/opt/cross-far
