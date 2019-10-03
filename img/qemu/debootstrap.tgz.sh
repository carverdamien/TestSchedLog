#!/bin/bash

set -x -e -u

TGZ="$1"

DEB=$(sudo mktemp -d "${BUILD_DIR}/debootstrap.XXXX")

sudo mkdir -p "${DEB}"
sudo debootstrap "--include=$(cat debootstrap.txt)" stable "${DEB}" http://http.debian.net/debian
sudo ./postdebootstrap.sh "${DEB}"
sudo tar -C "${DEB}" -czf "${TGZ}" .
sudo rm -rf "${DEB}"
sudo chown "${USER}:${USER}" "${TGZ}"
