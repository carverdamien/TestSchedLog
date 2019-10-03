#!/bin/bash
set -e -x -u

IMG="${1}"
TGZ="${2}"

! mount | grep "${IMG}"
sudo rm -fr "${IMG}.tmp" "${IMG}"

DEB=$(sudo mktemp -d "${BUILD_DIR}/debootstrap.XXXXXXXX")
sudo tar -C "${DEB}" -xzf "${TGZ}"
IMG_SIZE=$(sudo du -sb "${DEB}" | awk '{print int($1*110/100)}')
sudo qemu-img create -f raw "${IMG}" "${IMG_SIZE}"


MNT=$(sudo mktemp -d "${BUILD_DIR}/mnt.XXXXXXXX")

sudo mkfs.ext2 "${IMG}"
sudo mount -o loop "${IMG}" "${MNT}"

sudo cp -a "${DEB}/." "${MNT}/."

sudo umount "${MNT}"
sudo rmdir "${MNT}"
sudo rm -rf "${DEB}"
sudo chown "${USER}:${USER}" "${IMG}"
