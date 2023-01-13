#!/bin/bash
set -e

GCC_VER=2.7.2.3
#GCC_VER=2.95.3



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

function create_disk_images() {
	[ $# -eq 2 ]
	tarball="$1"
	destname="$2"

	[ -f "$tarball" ]
	[ "$destname" != "" ]

        rm "$destname*.dsk" || true

	split -b 1440k "$tarball" "$destname.dsk."

	parts="$(find -name "$destname.dsk.*" | sed 's/ /\n/g' | sort )"

	part_num=1
	last_part=none

	for f in $parts; do
	  last_part="$destname$part_num.dsk"
	  mv "$f" "$last_part"
	  part_num=$(( $part_num + 1 ))
	done

	pad_file "$last_part" 1474560
}

set -x

cs binutils-2.9.1.tar.gz af9718100fec5cd0588fe7351952be1895c351b7262b4e913c920d41bf816b4dfe1ddccc4aac2831bcdfe6f005751f0045b6766181403b2f95ea82b246e8b15c

tar xf binutils-2.9.1.tar.gz

patch -p1 -i binutils-2.9.1-changes.patch

export GCC_VER

case $GCC_VER in
  2.7.2.3)
   cs gcc-2.7.2.3.tar.gz 9e685f4cb10239387da6c253710e79e011b82288d49acda5ab9b8318e9bb553d05008a8dc15a14e44d6aa8346f3e941460082aedea3b927b632daee78f823209
   ;;
  2.95.3)
   cs gcc-2.95.3.tar.gz 50eb27613d5099bbcf2391b11d9818a7ff61f14fa0a01a04f956ce961cf59ccd32c4d7349ea18fdf29c2bec9126c3bda13e13715910b387c25b1bea1a557f485
   ;;
  *)
   echo "unknown version"
   exit 1
   ;;
esac

tar xf "gcc-$GCC_VER.tar.gz"

[ -d "gcc-$GCC_VER" ]

compiler_patch=gcc-$GCC_VER-changes.patch

if [ -f "$compiler_patch" ]; then
  patch -p1 -i "$compiler_patch"
fi

# create a far patched copy of the gcc src
if [ -d "gcc-$GCC_VER-far" ]; then
  rm -rf "gcc-$GCC_VER-far"
fi
cp -a "gcc-$GCC_VER" "gcc-$GCC_VER-far"

pushd "gcc-$GCC_VER-far"
if [ "$GCC_VER" == "2.95.3" ]; then
  # In this case where the host and target are the same but different from build
  # (so the compiler we're building is not technically a cross compiler, but a native compiler for a different machine)
  # gcc 2.95.3 scripts want to do fixinc... but you can't specify headers, so they do it on the build machine's headers.
  # This is broken and also stupid.
  # We already have the fixed headers for that arch from the cross compiler build, we can just disable the fixinc entirely
  # for this run, using this nice patch that lfs has
  patch -p1 -i ../gcc-2.95.3-no-fixinc.patch
fi
popd

# things from the aix machine we need

# - built libgcc1.a

[ -f libgcc1.a ]

# - includes

./headers.sh

# - libs

[ -f aixbaselib.dsk ]
[ -f aixlib1.dsk ]
[ -f aixlib2.dsk ]

cat aixbaselib.dsk > aixbaselib.tar.gz
gunzip -f aixbaselib.tar.gz || true

cat aixlib1.dsk aixlib2.dsk > aixlib.tar.gz
gunzip -f aixlib.tar.gz || true

mkdir -p sysroot
pushd sysroot
tar xf ../aixbaselib.tar
tar xf ../aixlib.tar
popd

# This will prepare the chroot and run the go_in_rpm_chroot.sh script inside to do the build
sudo GCC_VER="$GCC_VER" ./create_chroot.sh "$@"

rh5_chroot=/tmp/rh5_chroot

# pack the results

output_dir=/tmp/rh5_chroot/home/$USER/src/aix_toolchain_new/build-gcc

tar -C "$(dirname "$output_dir")" -czf crossnative-$GCC_VER.tar.gz "$(basename "$output_dir")"

create_disk_images crossnative-$GCC_VER.tar.gz crossnative-$GCC_VER-

output_dir=$rh5_chroot/root/opt/cross-far
tar -C "$(dirname "$output_dir")" -czf binutils.tar.gz "$(basename "$output_dir")"

./build_sysroot_headers.sh "$GCC_VER"
