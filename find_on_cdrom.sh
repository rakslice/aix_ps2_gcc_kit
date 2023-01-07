#!/bin/sh

for f in /mnt/cdrom/RedHat/RPMS/*.rpm; do rpm -qpl $f | fgrep "$1"  && echo $f; done
