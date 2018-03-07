#!/bin/bash -e

set -x

CONTAINER_NAME=$1

if [ -n "$2" ]
then
  RELEASE=$2
else
  RELEASE="artful"
fi

PUBLIC_KEY=$(cat /home/luc/.ssh/id_rsa.pub)

sudo lxc-create -t download -n $CONTAINER_NAME -- -d ubuntu -r $RELEASE -a amd64

cat <<EOF |

lxc.cgroup.devices.allow = a
lxc.mount.auto = cgroup:rw cgroup-full:rw proc:rw
lxc.apparmor.profile = unconfined
lxc.cap.drop =
EOF
sudo tee -a "/var/lib/lxc/$CONTAINER_NAME/config"


sudo lxc-start -n $CONTAINER_NAME

# some time for the network to be up
echo Short pause, to allow the network to be up
sleep 4

sudo lxc-attach -n $CONTAINER_NAME -- apt-get update
sudo lxc-attach -n $CONTAINER_NAME -- apt install -y openssh-server
sudo lxc-attach -n $CONTAINER_NAME -- mkdir /home/ubuntu/.ssh
sudo lxc-attach -n $CONTAINER_NAME -- bash -c "echo '$PUBLIC_KEY' >> /home/ubuntu/.ssh/authorized_keys"
sudo lxc-attach -n $CONTAINER_NAME -- chown -R ubuntu:ubuntu /home/ubuntu/.ssh
sudo lxc-attach -n $CONTAINER_NAME -- sed -i 's/%sudo\(.*\)ALL=(ALL:ALL) ALL/%sudo\1ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers

#TODO: private key, for github?

CONTAINER_IP=$(sudo lxc-ls -f | grep "$CONTAINER_NAME " | awk '{print $5}')

if grep -q $CONTAINER_NAME /etc/hosts
then
  sudo sed -i "s/.* $CONTAINER_NAME/$CONTAINER_IP $CONTAINER_NAME/" /etc/hosts
else
  echo "$CONTAINER_IP $CONTAINER_NAME" | sudo tee -a /etc/hosts
fi

# clean know_hosts if needed
sudo ssh-keygen -f "/root/.ssh/known_hosts" -R $CONTAINER_NAME
# add the new one
ssh-keyscan -t rsa $CONTAINER_NAME | sudo tee -a /root/.ssh/known_hosts

USERNAME_HOST="ubuntu@$CONTAINER_NAME"
SSH_CMD="ssh $USERNAME_HOST"

REMOTE_HOME="/home/ubuntu"

# setup ssh
## transfer the ssh keys
scp ~/.ssh/lxc/id_rsa* $USERNAME_HOST:.ssh/
## ensure github.com is a known host
$SSH_CMD "ssh-keyscan -t rsa github.com | tee -a $REMOTE_HOME/.ssh/known_hosts"
## copy the aws keys
scp -r ~/.ssh/aws $USERNAME_HOST:.ssh/

# install git, vim
$SSH_CMD sudo apt-get install -y git vim

# setup according to skyluc/config
$SSH_CMD mkdir -p $REMOTE_HOME/dev/skyluc
$SSH_CMD git clone -o perso git@github.com:skyluc/config $REMOTE_HOME/dev/skyluc/config
$SSH_CMD ln -s $REMOTE_HOME/dev/skyluc/config/apps/bash/.bash_aliases $REMOTE_HOME/.bash_aliases
$SSH_CMD ln -s $REMOTE_HOME/dev/skyluc/config/apps/git/.gitconfig $REMOTE_HOME/.gitconfig
$SSH_CMD ln -s $REMOTE_HOME/dev/skyluc/config/apps/git/.git_folder $REMOTE_HOME/.git
$SSH_CMD ln -s $REMOTE_HOME/dev/skyluc/config/apps/vim/.vimrc $REMOTE_HOME/.vimrc
$SSH_CMD ln -s $REMOTE_HOME/dev/skyluc/config/apps/vim/.vim $REMOTE_HOME/.vim

# install java
$SSH_CMD sudo apt-get install -y openjdk-8-jdk

# install misc
$SSH_CMD sudo apt-get install -y bash-completion

echo "All done. Use '$SSH_CMD' to connect"
