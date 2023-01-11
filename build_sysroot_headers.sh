#!/bin/bash
set -e -x

mkdir sysroot_headers

cp -av aixinclude/usr/include sysroot_headers
cp -av rh5_chroot/root/opt/cross/lib/gcc-lib/i386-ibm-aix/2.7.2.3/include sysroot_headers

output=sysroot_headers.tar.gz

if [ -f "$output" ]; then
	rm "$output"
fi
tar czf "$output" sysroot_headers
