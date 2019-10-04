#!/bin/bash
echo 1 | tee /sys/kernel/debug/sched_log/tracer/{enable,events/*}
cat /sys/kernel/debug/sched_log/tracer/logs/*
