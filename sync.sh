#!/bin/bash
set -e -x

git submodule init
git submodule sync --recursive
git submodule update --recursive --remote
