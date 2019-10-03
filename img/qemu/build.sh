#!/bin/bash
set -e -x -u

make
docker build --build-arg "KERNEL_IMG=${KERNEL_IMG}" -t "${QEMU_IMG}" .
