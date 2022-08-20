#!/bin/bash

mkdir -p logs

set_db_flag.sh "stress-ng=0"
set_db_flag.sh "rt=0"
set_db_flag.sh "gpu=0"
set_db_flag.sh "memtester=0"
set_db_flag.sh "badblocks=0"
set_db_flag.sh "enviro_test_long=1"
LOG_TIME=$(date +%y:%m:%d-%H:%M:%S)

#check for badblocks
set_db_flag.sh "badblocks=1"
badblocks -v /dev/mmcblk0 | tee "logs/${LOG_TIME}_badblocks.out"
set_db_flag.sh "badblocks=0"

#complete a memtest
set_db_flag.sh "memtester=1"
memtester 6G 1 | tee "logs/${LOG_TIME}_memtester.out"
set_db_flag.sh "memtester=0"

#GPU Checkout
set_db_flag.sh "gpu=1"
/usr/bin/cuda-samples/deviceQuery | tee "logs/${LOG_TIME}_deviceQuery.out"
/usr/bin/cuda-samples/mergeSort | tee "logs/${LOG_TIME}_mergeSort.out"
/usr/bin/cuda-samples/bandwidthTest | tee "logs/${LOG_TIME}_bandwidthTest.out"
/usr/bin/cuda-samples/UnifiedMemoryStreams | tee "logs/${LOG_TIME}_UnifiedMemoryStreams.out"
set_db_flag.sh "gpu=0"

#RT Test
set_db_flag.sh "rt=1"
#timeout 30s cyclictest --smp -p95 -m | tee "logs/${LOG_TIME}_cyclictest.out"
rt-migrate-test | tee "logs/${LOG_TIME}_rt-mitigate-test.out"
set_db_flag.sh "rt=0"

#Stress test
set_db_flag.sh "stress-ng=1"
stress-ng --cpu 8 --io 4 --vm 2 --vm-bytes 1G --fork 4 --timeout 600s | tee "logs/${LOG_TIME}_stress-ng.out"
set_db_flag.sh "stress-ng=0"

set_db_flag.sh "enviro_test_long=0"
set_db_flag.sh "stress-ng=0"
set_db_flag.sh "rt=0"
set_db_flag.sh "gpu=0"
set_db_flag.sh "memtester=0"
set_db_flag.sh "badblocks=0"