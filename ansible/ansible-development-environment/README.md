# Ansible Development Environment Lab

## Overview
The goal of this lab is to install Ansible for development and testing. We will install Ansible on a Fedora30 workstation vagrant box. This vagrant box is already provisioned with most of the required tools (VSCode, Git, Remmina, Python3) necessary to effectively construct and manage Ansible assets (playbooks, roles, inventory). We will install Ansible within Python virtual environments so that we may safely maintain multiple versions of Ansible.

## Steps
### Start Vagrant VDC
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
1. Execute `ansible --version`
1. Execute `ansible localhost -m ping`

### Additional Verification
1. Execute `vi ~/hosts.yaml`
1. Insert and save changes:
```
all:
  hosts:
    centos-host1:
      ansible_host: 192.168.60.98
    centos-host2:
      ansible_host: 192.168.60.99
```
3. `ansible -i hosts.yaml --private-key=/home/vagrant/.ssh/insecure_vagrant_rsa -m ping all`
4. `ansible -i hosts.yaml --private-key=/home/vagrant/.ssh/insecure_vagrant_rsa -m ping centos-host1`
5. `ansible -i hosts.yaml --private-key=/home/vagrant/.ssh/insecure_vagrant_rsa -m ping centos-host2`

### Deactivate Python Virtual Environment
1. `cd ~/py3venvironments/ansible-2.8.4`
1. `deactivate`

### Install Ansible 2.7.10 in Python Virtual Environment
1. `cd ~/py3venvironments`
Repeat above steps but replace `2.8.4` with `2.7.10`

*NOTE: You do not have to create or modify the `hosts.yaml` file.*

## External References

* [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

* [Ansible Release and Maintenance](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html)