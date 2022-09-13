#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Please add a name argument. Run $0 <TX2i ID>'
    exit 1
fi

echo "tx2i-sol-$1" > /etc/hostname
echo "127.0.1.1 tx2i-sol-$1" >> /etc/hosts
hostname tx2i-sol-$1

#set up eth IP addresses
sed -i 's/192.168.1.99/192.168.1.'$1'/' /etc/network/interfaces

ifdown eth0
ifup eth0






