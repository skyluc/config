#!/bin/bash -e

exec 3>&1
exec 4>&2

if ${DEBUG:-false}
then
  set -x
else
  exec 1> /dev/null
  exec 2> /dev/null
fi

function status() {
  echo "=== $1" >&3
}

function error() {
  echo "[error] $1" >&4
  exit 1
}

if [ -n "$1" ]
then
  CONTAINER_NAME=$1
else
  error "Missing container name."
fi

if [ -n "$2" ]
then
  RELEASE=$2
else
  RELEASE="19.10"
fi

PUBLIC_KEY=$(cat /home/luc/.ssh/id_rsa.pub)
REMOTE_HOME="/home/ubuntu"

status "Checking sudo status"

sudo true >&3 2>&4

status "Creating $CONTAINER_NAME with Ubuntu $RELEASE."

lxc launch ubuntu:$RELEASE $CONTAINER_NAME -c security.nesting=true -c security.privileged=true

status "Waiting for container to be in the right state."

RUNNING=false
for i in $(seq 1 10)
do
  sleep 1
  if (lxc exec $CONTAINER_NAME -- ls /home/ubuntu/.ssh/authorized_keys &> /dev/null)
  then
    RUNNING=true
    break
  fi
done

if [ ! $RUNNING ]
then
  error "Unable to find the expect file in the container. Something is wrong."
fi

DIRTY_CONTAINER_IP=$(lxc list -c n4s --format csv | grep "$CONTAINER_NAME" | awk -F ',' '{print $2}')
CONTAINER_IP=${DIRTY_CONTAINER_IP%% *}

status "Uploading public key."

lxc exec $CONTAINER_NAME -- bash -c "echo \"$PUBLIC_KEY\" >> $REMOTE_HOME/.ssh/authorized_keys"

status "Updating /etc/hosts."

# set or update the IP
if grep -q "${CONTAINER_NAME}\$" /etc/hosts
then
  sudo sed -i "s/.* $CONTAINER_NAME\$/$CONTAINER_IP $CONTAINER_NAME/" /etc/hosts
else
  echo "$CONTAINER_IP $CONTAINER_NAME" | sudo tee -a /etc/hosts
fi

status "Updating ~/.ssh/known_hosts."

# clean up
ssh-keygen -f "/home/luc/.ssh/known_hosts" -R $CONTAINER_NAME
ssh-keygen -f "/home/luc/.ssh/known_hosts" -R $CONTAINER_IP

# add new key
ssh-keyscan -t rsa $CONTAINER_NAME >> /home/luc/.ssh/known_hosts

status "Copying ssh keys."

USERNAME_HOST="ubuntu@$CONTAINER_NAME"
SSH_CMD="ssh $USERNAME_HOST"
SSH_CMD_INT="ssh -t $USERNAME_HOST"

# transfer the keys
scp ~/.ssh/lxd/id_rsa* $USERNAME_HOST:.ssh/
# ensure github.com is a known host
$SSH_CMD "ssh-keyscan -t rsa github.com >> $REMOTE_HOME/.ssh/known_hosts"

status "Upgrading packages to lastest versions."

$SSH_CMD sudo apt update
$SSH_CMD sudo apt upgrade -y

status "Setting user account using skyluc/config."

$SSH_CMD mkdir -p $REMOTE_HOME/dev/skyluc
$SSH_CMD_INT git clone -o upstream git@github.com:skyluc/config $REMOTE_HOME/dev/skyluc/config
$SSH_CMD ln -s $REMOTE_HOME/dev/skyluc/config/apps/bash/.bash_aliases $REMOTE_HOME/.bash_aliases
$SSH_CMD ln -s $REMOTE_HOME/dev/skyluc/config/apps/git/.gitconfig $REMOTE_HOME/.gitconfig
$SSH_CMD ln -s $REMOTE_HOME/dev/skyluc/config/apps/git/.git_folder $REMOTE_HOME/.git
$SSH_CMD ln -s $REMOTE_HOME/dev/skyluc/config/apps/vim/.vimrc $REMOTE_HOME/.vimrc
$SSH_CMD ln -s $REMOTE_HOME/dev/skyluc/config/apps/vim/.vim $REMOTE_HOME/.vim

status "Installing openjdk-8."

$SSH_CMD sudo apt install -y openjdk-8-jdk

status "Installing docker.io."

$SSH_CMD sudo apt install -y docker.io
# enabling user to use docker
$SSH_CMD "sudo sed -i 's/^\(docker:.*\)$/\1ubuntu/' /etc/group"

status "All done. Use '$SSH_CMD' to connect"

