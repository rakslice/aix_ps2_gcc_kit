#!/bin/bash
set -e -x

./cleanup_chroots

rh5_chroot=/tmp/rh5_chroot
sudo rm -rf cdrom_chroot $rh5_chroot/ build-binutils/ build-binutils.1/ build-gcc/ build-gcc.1/ build-gcc-native/ \
    sysroot/ aixinclude/ *.done binutils-2.9.1/ gcc-*/ crossnative.tar.gz crossnative*.dsk binutils.tar.gz \
    sysroot_headers/ sysroot_headers-*.tar.gz

