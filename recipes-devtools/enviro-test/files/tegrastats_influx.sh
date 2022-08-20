#!/bin/bash                                                                                                                                       
                                                                                
INFLUX_DB="http://192.168.1.110:8086/write?db=TX2i_db"                          
                                                                                
tegrastats |                                                                    
while IFS= read data                                                            
do                                                                              
    line=`echo $data | sed 's/^.*\(PLL\)/\1/'  \                                
        | awk -F "[/ @]" '/PLL/{OFS=","}{ print $1"="$2,$3"="$4,$5"="$6,$7"="$8,$9"="$10,$11"="$12,$13"="$14,$15"="$16" timestamp"}' \
        | sed "s/timestamp/$CURRENT_TIMESTAMP/" | sed "s/C,/,/g" | sed "s/C / /"`
    curl -X POST -d "tegrastats,host=${HOSTNAME} ${line}" $INFLUX_DB            
done