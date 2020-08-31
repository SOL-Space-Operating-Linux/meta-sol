#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a test_name=flag value. Ex: set_db_flag.sh vibe_x_axis=2.4'
    exit 1
fi


INFLUX_DB="http://192.168.1.110:8086/write?db=TX2i_db"

curl -X POST -d "test_metadata,host=${HOSTNAME} test_type.${1}" $INFLUX_DB 