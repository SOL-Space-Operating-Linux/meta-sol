#!/bin/bash

sync_time.bash
set_db_flag.sh "gpu=0"
set_db_flag.sh "stress-ng=0"
set_db_flag.sh "memtester=0"
set_db_flag.sh "rt=0"
python3 /usr/bin/tegra-pwrmon.py &
/usr/bin/tegrastats_influx.sh &
telegraf &








