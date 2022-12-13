#!/bin/bash                                                                                                                                       
                                                                                
tegrastats |                                                                    
while IFS= read data                                                            
do
    CURRENT_TIMESTAMP=$(date +%s)                                                                      
    line=`echo $data | sed 's/^.*\(PLL\)/\1/' | awk -F "[/ @]" '/PLL/{OFS=","}{ print $1"="$2,$3"="$4,$5"="$6,$7"="$8,$9"="$10,$11"="$12,$13"="$14,$15"="$16" timestamp000000000"}' | sed "s/timestamp/$CURRENT_TIMESTAMP/" | sed "s/C,/,/g" | sed "s/C / /"`
    echo "tegrastats,host=${HOSTNAME} ${line}"  
    exit 0          
done