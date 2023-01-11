#!/bin/bash
set -e -x

! diff -v 2>&1 | grep 'BusyBox'
# As of v1.35.0 busybox diff has a broken --no-dereference and will clutter the output with dupes
# ... Go install a real diff (e.g. apk add diffutils in alpine)

diff -ur --no-dereference orig mod | tee ../gcc-lib-include.patch
