#!/bin/bash
set -e -x -u

: ${TIMEOUT:=60 minutes}
: ${SSH_BIN:=$(which ssh)}
: ${SSH_KEY:=${PWD}/temporary-ssh-key}

main() {
    . img/names
    DID_FAIL=0
    if [ $# -eq 0 ]
    then
	test $(find tests -type f -name '*.test.sh')
    else
	test "${@}"
    fi
    exit ${DID_FAIL}
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
    MIN=4
    MemAvailable=$(awk '/MemAvailable:/{ print int($2*2^10/2^30) }' /proc/meminfo)
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
    # echo "docker stop ${cid}" | at now + ${TIMEOUT}
    IP=$(docker inspect ${cid} --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}')
    wait_vm
    for t in "${@}"
    do
	if ssh < "$t"
	then
	    echo "$t: OK"
	else
	    echo "$t: FAIL [$?]"
	    DID_FAIL=1
	fi
    done
    docker logs ${cid}
    docker stop ${cid}
}

fatal() {
    echo "$@" >&2
    exit 1
}

main "$@"
