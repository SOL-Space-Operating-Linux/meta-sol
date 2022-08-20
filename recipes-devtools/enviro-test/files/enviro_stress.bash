#!/bin/bash

trap ctrl_c INT

function ctrl_c() {
    set_db_flag.sh "stress_gpu=0"
    set_db_flag.sh "enviro_stress=0"
    set_db_flag.sh "stress-ng=0"
    killall stress-ng
    exit
}

set_db_flag.sh "stress-ng=0"
set_db_flag.sh "enviro_stress=1"
LOG_TIME=$(date +%y:%m:%d-%H:%M:%S)

#Stress test
set_db_flag.sh "stress-ng=1"
stress-ng --cpu 8 --io 4 --vm 2 --vm-bytes 1G --fork 4 --timeout 86400s &
set_db_flag.sh "stress-ng=0"

#GPU Stress (to some degree)
set_db_flag.sh "stress_gpu=1"
while true; do /usr/bin/cuda-samples/mergeSort; done




