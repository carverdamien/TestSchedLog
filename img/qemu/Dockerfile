ARG  KERNEL_IMG
FROM ${KERNEL_IMG}
COPY qemu.img /
COPY qemu.sh /usr/bin/
COPY .gdbinit /root/

ENV N_CORES=8 \
    N_SOCKETS=2 \
    N_CORES_PER_SOCKET=2 \
    N_THREADS_PER_CORE=2 \
    N_NUMA_NODES=2 \
    MEMORY=1G \
    KERNEL=/usr/src/linux/arch/x86_64/boot/bzImage \
    KDB=no

ENTRYPOINT [ "qemu.sh" ]
EXPOSE 22 1234
