#!/bin/bash
set -e -x

if [ ! -d build-gcc-native ]; then mkdir build-gcc-native; fi
cd build-gcc-native

if [ ! -f .configure.done ]; then

../gcc-$GCC_VER/configure --enable-languages=c,c++ --prefix=/usr/local
touch .configure.done

fi

make LANGUAGES=c "$@"
make LANGUAGES=c install

cd ..
