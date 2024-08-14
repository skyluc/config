# Setup (from 2024)

To use priviledge mode, the su account has to be used to create the instances

* Check the github keys for the lxd instances.

  The keys are expected to be at `~/.ssh/lxd/id_ed25519` and `~/.ssh/lxd/id_ed25519.pub`.

  The public key needs to be added at [https://github.com/settings/keys].

* Install `lxd` from snap

  ```
  sudo snap install --classic lxd
  ```

* Create and set the btrfs storage pool
  
  ```
  sudo lxc storage create default btrfs source=/data/lxc-storage
  sudo lxc profile device add default root disk path=/ pool=default
  ```

* Create and set the btrfs storage pool
  
  ```
  sudo lxc storage create default zfs zfs.pool_name=lxc-pool
  sudo lxc profile device add default root disk path=/ pool=default
  ```

* Initialize lxd

  ```
  sudo lxd init
  ```

  All defaults, expect creating storage pool, as it was already done in the previous step.

* Create the instance

  ```
  lxd-setup.sh test01
  ```

* Connect to the instance

  ```
  ssh ubuntu@test01
  ```

# packages

`lxc` (apt), `lxd` (snap)

# btrfs default storage pool

* create the btrfs storage pool
  ```
  lxc storage create default btrfs source=/data/lxc-storage
  ```
  * `/data` is the root of the btrfs volume
  * `/data/lxc-storage` is a new folder in the btrfs volume. All data inside it will be deleted

* set the pool in the default profile
  ```
  lxc profile device add default root disk path=/ pool=default
  ```

# add default bridge to default profile

```
lxc profile device add default eth0 nic nictype=bridged parent=lxcbr0
```

Additional setting for the bridge, to be compatible with the DA VPN

```
lxc network set bridge bridge.mtu=1400
```

# support for docker in container

* create a btrfs storage pool for docker
  ```
  lxc storage create docker btrfs source=/data/lxc-docker
  ```
  * `/data` is the root of the btrfs volume
  * `/data/docker` is a new folder in the btrfs volume. All data inside it will be deleted
* create a new volume on the pool
  ```
  lxc storage volume create docker demo
  ```
* attach volume to the container
  ```
  lxc config device add demo docker disk pool=docker source=demo path=/var/lib/docker
  ```
* tweak the security to allow docker to access system calls
  ```
  lxc config set demo security.nesting=true security.syscalls.intercept.mknod=true security.syscalls.intercept.setxattr=true
  ```
* log in the container
  ```
  lxc exec demo bash
  ```
* Add needed packages
  ```
  sudo apt update
  # sudo apt install ca-certificates curl gnupg lsb-release
  sudo apt install snapd containerd
  ```
* restart instance
  ```
  lxc restart demo
  lxc exec demo bash
  ```
* 
  ```
  sudo snap install docker
  ```
* install the 
