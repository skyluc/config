
# ssh key creation 

(from the GitHub documentation)

* create the `.ssh/id_ed25519` key pair.
  ```
  ssh-keygen -t ed25519 -C "lb@skyluc.org"
  ```
* add the key to ssh-agent
  ```
  ssh-add .ssh/id_ed25519
  ```