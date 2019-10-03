#!/bin/bash

set -x -e -u

detect_privileged() {
    ip link add dummy0 type dummy >/dev/null &&
	ip link delete dummy0 >/dev/null
}

if detect_privileged
then
    FLAGS="--enable-kvm"
else
    FLAGS=""
fi

NUMA=
if [[ ${N_NUMA_NODES} -gt 0 ]]
then
    for ((i=1; i<=N_NUMA_NODES; i++))
    do
	NUMA="$NUMA -numa node,nodeid=$((i-1))"
    done
fi

v=$((N_SOCKETS * N_CORES_PER_SOCKET * N_THREADS_PER_CORE))
if [ ${v} -ne ${N_CORES} ]; then
    echo "Invalid configuration. N_CORES != (N_SOCKETS * N_CORES_PER_SOCKET * N_THREADS_PER_CORE)"
    exit 1
fi

DRIVEA="-drive file=/qemu.img,format=raw"
ROOT="/dev/sda"

VIRTFS=" --virtfs local,path=/,mount_tag=rootfs,security_model=mapped,id=rootfs "
VIRTFS+=" --virtfs local,path=/root/.ssh,mount_tag=rootssh,security_model=mapped,id=rootssh "

case "${KDB}" in
    yes|y|1)
	CMDLINE="root=${ROOT} rw vga=f07 console=ttyS0 kgdboc=ttyS1 kgdbwait"
	;;
    no|n|0)
	CMDLINE="root=${ROOT} rw vga=f07 console=ttyS0 kgdboc=ttyS1"
	;;
    *)
	echo 'KDB=${KDB} unrecognized'
	exit 1
	;;
esac

SMP="-smp ${N_CORES},sockets=${N_SOCKETS},cores=${N_CORES_PER_SOCKET},threads=${N_THREADS_PER_CORE} ${NUMA}"
# SMP=""

exec qemu-system-x86_64 ${FLAGS} \
     ${SMP} \
     ${DRIVEA} ${VIRTFS} \
     -chardev stdio,id=std,signal=off \
     -serial chardev:std \
     -serial tcp::1234,server,nowait \
     -boot c -m ${MEMORY} \
     -kernel "${KERNEL}" \
     -append "${CMDLINE}" \
     -net user,hostfwd=tcp::22-:22 \
     -net nic \
     -display none
