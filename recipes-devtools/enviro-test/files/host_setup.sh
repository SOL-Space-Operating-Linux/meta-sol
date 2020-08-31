#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Please add a name argument. Run $0 <TX2i ID>'
    exit 1
fi

echo "tx2i-sol-$1" > /etc/hostname
echo "127.0.1.1 tx2i-sol-$1" >> /etc/hosts


#add ssh keys to apldds
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub | ssh aplsim@192.168.1.110 'umask 0077; mkdir -p .ssh; cat >> .ssh/authorized_keys && echo "Key copied"'


#set up eth IP addresses
sed -i 's/192.168.1.99/192.168.1.'$1'/' /etc/systemd/network/20-eth.network






