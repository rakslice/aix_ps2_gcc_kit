#!/bin/bash
set -e -x
export PREFIX="$HOME/opt/cross"
export TARGET=i386-ibm-aix
export PATH="$PREFIX/bin:$PATH"

bash


