# SSH Bastion Host Lab

This solution allows users to use Vagrant ([http://www.vagrantup.com](http://www.vagrantup.com)) to quickly and easily provision an environment for learning and working with SSH bastion hosts and proxy commands. This environment was created and tested using VirtualBox, VMware Fusion, and Vagrant.

## Assets

* **bastion\_rsa** and **bastion\_rsa.pub**: Private/public key pair for accessing the SSH bastion host. The password for this key pair is `password` (all lowercase). These files are automatically installed by Vagrant into the correct VMs.

* **bastion-hosts**: This snippet of an `/etc/hosts` file contains IP addresses for the remote SSH destinations. It is added to `/etc/hosts` on the bastion host automatically by Vagrant during provisioning.

_NOTE: `/etc/hosts` does not need to be manipulated. It is a way but it may not always be the right way. You can add `Hostname` to the `ssh config` or `ssh.cfg` file on the client that will ssh to the remote host._

* **client-ssh-config**: This is an SSH configuration file that sets up the SSH bastion host configuration. This file is installed automatically by Vagrant into the client VM, but must be edited to properly reflect the IP address assigned to the bastion host (see the instructions below).

* **README.md**: This file you're currently reading.

* **remote\_rsa** and **remote\_rsa.pub**: Private/public key pair for accessing the remote SSH nodes behind the bastion host. The password for this key pair is `secure` (all lowercase). The `Vagrantfile` will automatically place these files in the correct locations on the appropriate VMs.

* **machines.yml**: This YAML file contains a list of VM definitions and associated configuration data. It is referenced by `Vagrantfile` when Vagrant instantiates the VMs. Generally, this is the _only_ file that requires any edits; you'll edit this file to specify the correct Vagrant box installed on your system.

* **ssh-bastion-diagram.png**: This PNG diagram provides a graphical overview of the different VMs in this environment and how they are connected.

* **Vagrantfile**: This file is used by Vagrant to spin up the virtual machines. This file is fairly extensively commented to help explain what's happening. You should be able to use this file unchanged; all the VM configuration options are stored outside this file.

## Getting Started
The goal of this lab is to provision a multi-machine Vagrant environment in which a client and bastion host reside in a network (mock public network) and two remote servers reside in a private network. The client must proxy through the bastion host to access the remote servers in the private network. The Vagrant managed virtual data center to be provisioned is described in the following diagram.

![ssh-bastion-diagram.png](ssh-bastion-diagram.png)

These instructions assume you've already installed VirtualBox and Vagrant. Please refer to the documentation for those products for more information on installation or configuration.


### VirtualBox
https://www.virtualbox.org/wiki/Downloads
 
Windows users will want to install the VirtualBox 6.1.0 platform for Windows hosts
https://download.virtualbox.org/virtualbox/6.0.10/VirtualBox-6.0.10-132072-Win.exe
 
_Note: Do NOT install VirtualBox Extension Pack or Software Developer Kit. Both of these packages are not needed and the Extension Pack requires an Enterprise license._
 
### Vagrant
https://www.vagrantup.com/
 
Windows users will want to install the Windows 64bit package
https://releases.hashicorp.com/vagrant/2.2.5/vagrant_2.2.5_x86_64.msi

https://www.virtualbox.org/wiki/Documentation

https://www.vagrantup.com/docs/

1. Use `vagrant box add {{ BOX_NAME }}` to add a CentOS 7 base box to be used by this `Vagrantfile`. (Example: `vagrant box add centos/7` and choose `3` for the VirtualBox flavor)

1. Use `vagrant box add {{ BOX_NAME }} --box-version {{ BOX_VERSION }}` to add a CentOS 7 base box to be used by this `Vagrantfile`. (Example: `vagrant box add gusztavvargadr/windows-server --box-version 1809.0.1907-standard` and choose `2` for the VirtualBox flavor)

1. Edit the `machines.yml` file to ensure the box you downloaded in step 1 is specified on the "box:" line of this file for each VM. (By default, there are four VMs, so make sure to specify the correct box name for all four VMs.)

1. Run `vagrant up`, and when the VMs are finished provisioning run `vagrant ssh-config bastion`.

1. Run `vagrant ssh client` to access the SSH client VM.

1. Use the editor of your choice to edit `~/.ssh/config` on the client VM to specify the correct address for the bastion host (look for the `Hostname` line). Save the changes to this file.

1. Use `ssh remote1` or `ssh remote2` to establish an SSH session _through_ the bastion host, as specified by the `ProxyCommand` in the SSH configuration file.

_NOTE: The passphrase for `bastion_rsa` is "password"; for `remote_rsa` the passphrase is "secure"._

_TIP: You can start `ssh agent` and store your private keys and passphrases but there are security ramifications to consider._


Enjoy!
