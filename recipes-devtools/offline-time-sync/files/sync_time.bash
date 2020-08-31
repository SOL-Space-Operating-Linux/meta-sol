#!/bin/bash
LAPTOP_DATE=`ssh aplsim@192.168.1.110 'date -u +"%Y-%m-%d %H:%M:%S"'`
echo "Setting onboard clock to ${LAPTOP_DATE}"
date --set="${LAPTOP_DATE}"
hwclock -w
