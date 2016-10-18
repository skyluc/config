#!/bin/bash -e

CONTAINER_NAME=$1

PUBLIC_KEY=$(cat /home/luc/.ssh/id_rsa.pub)

lxc-attach -n $CONTAINER_NAME -- apt install -y openssh-server
lxc-attach -n $CONTAINER_NAME -- mkdir /home/ubuntu/.ssh
lxc-attach -n $CONTAINER_NAME -- bash -c "echo '$PUBLIC_KEY' >> /home/ubuntu/.ssh/authorized_keys"
lxc-attach -n $CONTAINER_NAME -- chown ubuntu:ubuntu /home/ubuntu/.ssh
lxc-attach -n $CONTAINER_NAME -- sed -i 's/%sudo\(.*\)ALL=(ALL:ALL) ALL/%sudo\1ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers

#TODO: private key, for github?

CONTAINER_IP=$(lxc-ls -f | grep $CONTAINER_NAME | awk '{print $5}')

sudo sed -i "s/.* $CONTAINER_NAME/$CONTAINER_IP $CONTAINER_NAME/" /etc/hosts

# clean know_hosts if needed
ssh-keygen -f "/home/luc/.ssh/known_hosts" -R $CONTAINER_NAME
