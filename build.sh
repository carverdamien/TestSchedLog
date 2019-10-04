#!/bin/bash
set -e -x

. img/names
(cd img/kernel; ./build.sh)
(cd img/qemu; ./build.sh)
