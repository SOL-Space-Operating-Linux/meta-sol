#!/bin/bash
LAPTOP_DATE=`ssh eric@192.168.1.110 'date -u +"%Y-%m-%d %H:%M:%S"'`
echo "Setting onboard clock to ${LAPTOP_DATE}"
date --set="${LAPTOP_DATE}"
hwclock -w
echo "CURRENT TIME = $(date +%s)" > /dev/kmsg