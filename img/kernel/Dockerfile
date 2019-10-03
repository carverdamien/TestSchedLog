FROM ubuntu
COPY requirements.txt /root/requirements.txt
RUN apt-get update \
 && apt-get install -y $(cat /root/requirements.txt)
COPY src /usr/src/linux
COPY qemu_debug.config /usr/src/linux/arch/x86/configs/
WORKDIR /usr/src/linux
RUN make defconfig sched_log.config kvm_guest.config qemu_debug.config
RUN make -j $(nproc)
