# Add New Client to Public Network
## Overview

The goals of this lesson are:

* Add a Fedora Linux client to existing public network (192.168.60.*)
* Configure this client, the bastion, and the servers in the private network to allow SSH communication
* Validate SSH connection between this client, the bastion host, and the private servers

## Lesson
### Add Fedora Linux client

Our goal is to add the `ryancraig/fedora-iac-dev-ws` vagrant box to our public network. This vagrant box (currently only built for the VirtualBox provider) is built using the project `https://github.com/ryancraig/packer-fedora`. It's published to the [HashiCorp Vagrant Cloud](https://app.vagrantup.com/ryancraig/boxes/fedora-iac-dev-ws). This box is currently a Fedora 30 Linux workstation with Git, VSCode, Remmina, Google Chrome, Firefox, and Docker CE installed and configured. In later lessons we will finish configuring this client for use as a Infrastructure as Code development workstation.

#### Steps

1. Add the box to Vagrant
`vagrant box add ryancraig/fedora-iac-dev-ws`

1. Locate `machines.yml` file in the `learning-tools/ssh/ssh-bastion` path

1. Append the following content to the `machines.yml` file and save changes

```
- name: "dev-client"
  vmw_box: "ryancraig/fedora-iac-dev-ws"
  vb_box: "ryancraig/fedora-iac-dev-ws"
  #box_url: 
  ram: "2048"
  vcpu: "2"
  mock_public_ip_addr: "192.168.60.31"
```

1. Start `dev-client`. In a terminal/cmd session, navigate to `learning-tools/ssh/ssh-bastion` and execute `vagrant up dev-client`.
*NOTE: After importing this box, a VirtualBox GUI emulator window start and you should automatically be authenticated as the `vagrant` user.*

1. In the `dev-client` VirtualBox GUI emulator window, open `terminal`

1. In `terminal`, execute `whoami` to ensure you're authenticated as the `vagrant` user

1. In `terminal`, execute `users` to ensure `vagrant` is the only non-root user

1. In `terminal`, execute `groups` to ensure `vagrant` and `docker` are the only unprivileged groups

1. In `terminal`, execute `vi ~/.ssh/authorized_keys`, verify that the only key entry is the vagrant insecure key, and close the file `:q`

You should see that `vagrant` is the only user, `vagrant` and `docker` groups exist, and the only authorized key for SSH use is the vagrant insecure key.

### Configure this client, the bastion, and the servers in the private network to allow SSH communication

Our goal is to configure SSH communication between the new client, the bastion host, and the remote servers in the private (remote) network. This effort requires adding keys on the client and adding an entry in the `authorized_keys` file on the bastion and remote servers.

#### Steps

1. On your workstation (vagrant host), locate `vagrant_insecure_rsa` (RSA private key) and `vagrant_insecure_rsa.pub` (RSA public key) file in the `learning-tools/ssh/ssh-bastion` path

1. On your workstation (vagrant host), copy the private key file to the `dev-client` vagrant box. Place this key file in the `/home/vagrant/.ssh` path.
*NOTE: I use scp to copy files from my host to vagrant boxes. For example: `scp -i vagrant_insecure_rsa -P 2222 vagrant_insecure_rsa vagrant@localhost:~/.ssh`.*

1. On the `dev-client` vagrant box, change security on the key file. In terminal, execute `chmod 400 ~/.ssh/vagrant_insecure_rsa`.

1. Verify you can establish an SSH session from `dev-client` to `bastion`. On your workstation, `vagrant up bastion`. On the `dev-test` box, in terminal, execute `ssh -i ~/.ssh/vagrant_insecure_rsa 192.168.60.100`. *NOTE: An SSH session should be established successfully.*

1. In the `bastion` SSH session, `vi ~/.ssh/authorized_keys`. See that the vagrant insecure public key entry exists. This entry allows you to establish a SSH session; without it your request would be denied. Exit vi, execute `:q` and hit `ENTER`.

1. On your workstation, locate the `client-ssh-config` file and copy it to the `dev-client` box as `ssh.conf`. *NOTE: I use scp to copy files from my host to vagrant boxes. For example: `scp -i vagrant_insecure_rsa -P 2222 client-ssh-config vagrant@localhost:~/.ssh/ssh.conf`.*

1. On the `dev-client` box, modify the `ssh.conf` file contents as below:
```
Host bastion
  Hostname 192.168.60.100
  IdentityFile ~/.ssh/vagrant_insecure_rsa
  User vagrant

Host remote1
  Hostname 10.100.60.11
  IdentityFile ~/.ssh/vagrant_insecure_rsa
  ProxyCommand ssh bastion -W %h:%p -F ssh.conf

Host remote2
  Hostname 10.100.60.12
  IdentityFile ~/.ssh/vagrant_insecure_rsa
  ProxyCommand ssh bastion -W %h:%p -F ssh.conf

# Windows 2019 server with OpenSSH configured
Host remote3
  Hostname 10.100.60.13
  IdentityFile ~/.ssh/vagrant_insecure_rsa
  ProxyCommand ssh bastion -W %h:%p -F ssh.conf
```
1. On the `dev-client` box, change security on the `ssh.conf` file. In terminal, execute `chmod 400 ~/.ssh/ssh.conf`.

1. Verify you can establish an SSH session from `dev-client` to `bastion` using the `ssh.conf`. On your workstation, `vagrant up bastion` (If the bastion host is not already running; if it's running skip executing this command). On the `dev-test` box, in terminal, execute `ssh -F ~/.ssh/ssh.conf bastion`. *NOTE: An SSH session should be established successfully. Although the ssh.conf file or using the default ~/.ssh/conf file is unnecessary to successfully establish an SSH session with a remote server if does make it easier especially when jumping through a bastion host to a private remote server.*

1. Verify you can establish an SSH session from `dev-client` to `remote` using the `ssh.conf`. On your workstation, `vagrant up remote1` (If the bastion host is not already running; if it's running skip executing this command). On the `dev-test` box, in terminal, execute `ssh -F ~/.ssh/ssh.conf bastion`.

1. For extra credit, replace the use of the non-standard `ssh.conf` file with the standard `.ssh/config` file. You will have to create the `config` file. Add the following contents:
```
Host bastion
  Hostname 192.168.60.100
  IdentityFile ~/.ssh/vagrant_insecure_rsa
  User vagrant

Host remote1
  Hostname 10.100.60.11
  IdentityFile ~/.ssh/vagrant_insecure_rsa
  ProxyCommand ssh bastion -W %h:%p

Host remote2
  Hostname 10.100.60.12
  IdentityFile ~/.ssh/vagrant_insecure_rsa
  ProxyCommand ssh bastion -W %h:%p

# Windows 2019 server with OpenSSH configured
Host remote3
  Hostname 10.100.60.13
  IdentityFile ~/.ssh/vagrant_insecure_rsa
  ProxyCommand ssh bastion -W %h:%p
  ```
  
  *NOTE: Review the differences between the contents of `ssh.conf` and `conf`. Also note that `ssh.conf` can live anywhere on the local file system whereas `conf` is expected to be in the `~/.ssh/` path.*