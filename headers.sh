#!/bin/bash

set -e -x


[ -f aixinclude.dsk ]


cat aixinclude.dsk > aixinclude.tar.gz
gunzip -f aixinclude.tar.gz || true


mkdir -p aixinclude
pushd aixinclude
tar xf ../aixinclude.tar
cd usr
patch -p2 -i ../../includes.patch
popd
