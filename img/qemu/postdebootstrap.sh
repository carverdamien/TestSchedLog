#!/bin/bash
# https://blog.nelhage.com/2013/12/lightweight-linux-kernel-development-with-kvm/

set -e -x -u

cd "${1}"

# Make root passwordless for convenience.
sed -i '/^root/ { s/:x:/::/ }' etc/passwd

# ssh root login
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' etc/ssh/sshd_config

# Root Autologin
sed -i 's/ExecStart=.*/ExecStart=-\/sbin\/agetty -a root --keep-baud 115200,38400,9600 %I $TERM/' 'lib/systemd/system/serial-getty@.service'

# Change /etc/network/interfaces so Internet can be used directly after
# connection.
ETHER='enp0s3'
echo -e "# The loopback network interface\nauto lo\niface lo inet loopback\n\n# The primary network interface\nallow-hotplug ${ETHER}\niface ${ETHER} inet dhcp" > etc/network/interfaces

mkdir rootfs
echo 'rootfs /rootfs 9p trans=virtio,version=9p2000.L,rw,nofail,x-systemd.device-timeout=1 0 0' >> etc/fstab
mkdir -p /root/.ssh
echo 'rootssh /root/.ssh 9p trans=virtio,version=9p2000.L,rw,nofail,x-systemd.device-timeout=1 0 0' >> etc/fstab
