#!/bin/bash
set -e -x

./cleanup_chroots

sudo rm -rf cdrom_chroot rh5_chroot/ build-binutils/ build-binutils.1/ build-gcc/ build-gcc.1/ \
    sysroot/ aixinclude/ *.done binutils-2.9.1/ gcc-2.7.2.3/ crossnative.tar.gz crossnative*.dsk

