#!/bin/bash
echo 1 | tee /sys/kernel/debug/sched_log/tracer/{enable,events/*}
hackbench
cat /sys/kernel/debug/sched_log/tracer/logs/* > /dev/null
