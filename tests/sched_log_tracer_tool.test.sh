#!/bin/bash
set -e -x -u

sched_log() { /rootfs/usr/src/linux/tools/sched_log/sched_log $@; }

sched_log reset tracer
sched_log start tracer
hackbench
sched_log stop tracer
sched_log dump /rootfs/tmp/dump tracer
find /rootfs/tmp/dump

sched_log reset tracer
sched_log start tracer
hackbench
sched_log stop tracer
sched_log dump-raw /rootfs/tmp/dump-raw tracer
find /rootfs/tmp/dump-raw
