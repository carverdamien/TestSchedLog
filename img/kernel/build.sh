#!/bin/bash
set -e -x -u

docker build -t "${KERNEL_IMG}" .
