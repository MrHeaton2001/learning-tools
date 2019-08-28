# Ansible Development Environment Lab

## Overview
The goal of this lab is to install Ansible for development and testing. We will install Ansible on a Fedora30 workstation vagrant box. This vagrant box is already provisioned with most of the required tools (VSCode, Git, Remmina, Python3) necessary to effectively construct and manage Ansible assets (playbooks, roles, inventory). We will install Ansible within Python virtual environments so that we may safely maintain multiple versions of Ansible.

## Steps
### Start Vagrant VDC

On your host:
1. Navigate to `/ansible` in your `learning-tools` local git repo
1. Execute `vagrant up`

### Install Latest Ansible in Python Virtual Environment
1. In `ansible-dev-ws` VirtualBox VM window, launch `terminal`
1. Execute `mkdir py3venvironments && cd $_`
1. Execute `python3 -m venv ansible-2.8.4/.env`
1. Execute `source ansible-2.8.4/.env/bin/activate`
1. Execute `python --version`
1. Execute `pip install --upgrade pip`
1. Execute `pip install ansible==2.8.4`

*Note: `--system-site-packages` gives the virtual environment access to the system site-packages dir. This is necessary when running Ansible on nodes that implement SELinux. The SELinux Python library is installed system wide but not in each individual python virtual environment. If SELinux is enabled on your workstation or production Ansible controller host you may need to execute `python3 -m venv ansible-2.8.4/.env --system-site-packages`. For this lab SELinux is disabled on the Fedora30 development workstation. This may change in the future as there are security ramifications.*

### Verify Install
In `ansible-dev-ws` VirtualBox VM window, in `terminal`:
1. Execute `ansible --version`
1. Execute `ansible localhost -m ping`

### Additional Verification
In `ansible-dev-ws` VirtualBox VM window, in `terminal`:
1. Execute `vi ~/hosts.yaml`
1. Insert and save changes:
```
all:
  hosts:
    centos-host1:
      ansible_host: 192.168.60.91
    centos-host2:
      ansible_host: 192.168.60.92
```
3. `ansible -i ~/hosts.yaml --private-key=/home/vagrant/.ssh/vagrant_insecure_rsa -m ping all`
4. `ansible -i ~/hosts.yaml --private-key=/home/vagrant/.ssh/vagrant_insecure_rsa -m ping centos-host1`
5. `ansible -i ~/hosts.yaml --private-key=/home/vagrant/.ssh/vagrant_insecure_rsa -m ping centos-host2`

### Deactivate Python Virtual Environment
In `ansible-dev-ws` VirtualBox VM window, in `terminal`:
1. `cd ~/py3venvironments/ansible-2.8.4`
1. `deactivate`

### Install Ansible 2.7.10 in Python Virtual Environment
In `ansible-dev-ws` VirtualBox VM window, in `terminal`:
1. `cd ~/py3venvironments`
Repeat above steps but replace `2.8.4` with `2.7.10`

*NOTE: You do not have to create or modify the `hosts.yaml` file.*

### Install VSCode Extension for Ansible
In `ansible-dev-ws` VirtualBox VM window:
1. Launch `VSCode`
1. In `VSCode`, go to `File` > `Preferences` > `Extensions`, find and install `VS Code extension for Ansible`

### Shutdown Vagrant VDC
When you are finished with this lesson and you are ready to release the resources the Vagrant VDC are utilizing:

1. On your Vagrant host, `cd` to `/ansible/ansible-development-environment` path within your local `learning-tools` git repo
1. Finally, on your Vagrant host, in a terminal, execute `vagrant halt`

## External References
### Ansible

* [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

* [Ansible Release and Maintenance](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html)

* [Ansible Getting Started](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html)

### Python3 Virtual Environments

* [Python3: Tutorial - Virtual Environments and Packages](https://docs.python.org/3/tutorial/venv.html)

* [Python3: Creating Virtual Environments](https://packaging.python.org/tutorials/installing-packages/#creating-virtual-environments)

* [Python3: `venv` - Creation of virtual environments](https://docs.python.org/3/library/venv.html)

* [TowardsDataScience.com: All you need to know about Python virtual environments](https://towardsdatascience.com/all-you-need-to-know-about-python-virtual-environments-9b4aae690f97)
