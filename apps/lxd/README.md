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
