#!/bin/bash
set -e -x

git submodule init
git submodule sync --recursive
git submodule update --recursive --remote
export KERNEL_IMG="testschedlog-kernel:$(cd img/kernel/src; git rev-parse HEAD)"
(cd img/kernel; ./build.sh)
export QEMU_IMG="testschedlog-qemu:$(git rev-parse HEAD)"
(cd img/qemu; ./build.sh)
