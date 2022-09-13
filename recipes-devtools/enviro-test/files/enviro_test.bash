#!/bin/bash

trap ctrl_c INT

arg=$1

function ctrl_c() {
    set_db_flag.sh "$arg=0"
    exit
}

if [[ $# -eq 0 ]] ; then
    echo "Please add a name argument. Run $0 <Test Type>"
    exit 1
fi

if [ $1 = "gpu" ] ; then
    echo 'GPU Test'
    set_db_flag.sh "gpu=1"
    while true; do
        /usr/bin/cuda-samples/deviceQuery | ts %s
        /usr/bin/cuda-samples/bandwidthTest | ts %s
        /usr/bin/cuda-samples/mergeSort | ts %s
        /usr/bin/cuda-samples/UnifiedMemoryStreams | ts %s
    done
fi


if [ $1 = "stress-ng" ] ; then
    echo 'Stress Test'
    set_db_flag.sh "stress-ng=1"
    stress-ng --cpu 8 --io 4 --vm 2 --vm-bytes 1G --fork 4 --timeout 86400s | ts %s
fi

if [ $1 = "mem" ] ; then
    echo 'Mem Test'
    set_db_flag.sh 'mem=1'
    memtester 5G 1 | ts %s
fi

if [ $1 = "rt" ] ; then
    echo 'RT Test'
    set_db_flag.sh "rt=1"
    while true; do rt-migrate-test | ts %s; done
fi