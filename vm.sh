#!/bin/bash
set -e -u

: ${TIMEOUT:=5 minutes}
: ${SSH_BIN:=$(which ssh)}
: ${SSH_KEY:=${PWD}/temporary-ssh-key}

main() {
    . img/names
    test
}

ssh () {
    sudo ${SSH_BIN} \
	 -i ${SSH_KEY} \
	 -o UserKnownHostsFile=/dev/null \
	 -o StrictHostKeyChecking=no \
	 root@${IP} \
	 "$@"
}

wait_vm() {
    until ssh echo ok
    do
	echo 'Waiting for VM'
	sleep 1
    done
}

MEMORY() {
    # in GB
    MemAvailable=$(awk '/MemAvailable:/{ print int($2*2^10/2^30) }' /proc/meminfo)
    MIN=$((MemAvailable/2))
    [[ $MemAvailable -gt $MIN ]] ||
	fatal "Not enough MEMORY on $HOSTNAME"
    echo "${MIN}G"
}

test() {
    sudo rm -f "${SSH_KEY}" "${SSH_KEY}.pub"
    sudo ssh-keygen -f "${SSH_KEY}" -P ''
    cid=$(docker run \
		 -e MEMORY=$(MEMORY) \
		 --cpus 2 \
		 -v "${SSH_KEY}.pub:/root/.ssh/authorized_keys" \
		 -d \
		 --privileged \
		 -ti \
		 --rm \
		 ${QEMU_IMG})
    IP=$(docker inspect ${cid} --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}')
    wait_vm
    ssh
}

fatal() {
    echo "$@" >&2
    exit 1
}

main "$@"
