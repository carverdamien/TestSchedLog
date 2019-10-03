#!/bin/bash
set -e -x

git submodule init
git submodule sync --recursive
git submodule update --recursive --remote
. img/names
(cd img/kernel; ./build.sh)
(cd img/qemu; ./build.sh)
