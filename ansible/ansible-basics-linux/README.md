# Ansible basics

## Overview
We will learn the basics of Ansible using the default Ansible installation which currently only allows us to control Linux hosts. In future lessons, we'll learn how to install and configure Ansible extensions that allow us to communication with and control Windows hosts via WinRM.

The goals of this lab are:

* Learn the Ansible configuration hierarchy
* Learn about Ansible Hosts Inventory
* Briefy learn about Ansible Adhoc Commands
* Learn about playbook structure

## Start the Vagrant VDC
We will use 4 vagrant boxes for this lesson. `ansible-dev-ws` is the Fedora30 workstation provisioned as an Ansible development workstation and Ansible controller. `centos7-host[1..3]` are three basic CentOS 7 headless servers.

1. On your Vagrant host workstation, execute `vagrant up`

1. Once all vagrant boxes are running, execute `vagrant status` to verify the status of each vagrant box. All four boxes should be running.

## Fetch `ansible-examples` git repo
The `ansible-examples` git repo contains example Ansible assets such as hosts inventory files, playbooks, RSA key pairs, and configuration files used to showcase specific Ansible features and implementation options and best practices.

1. On `ansible-dev-ws`, launch `terminal`, execute `cd ~`

1. On `ansible-dev-ws`, fetch the [ansible-examples git repo](https://github.com/ryancraig/ansible-examples). In `terminal` execute `git clone https://github.com/ryancraig/ansible-examples.git` or `git pull https://github.com/ryancraig/ansible-examples.git` if you already have a local repo.


## Ansible Configuration
We will deploy a valid `ansible.cfg` file to the user home, current directory, and then create `ANSIBLE_CONFIG` environment variable to see Ansible's configuration search behavior in action.

*NOTE: We will NOT deploy `ansible.cfg` to `/etc/ansible`.* 

### Steps
#### Deploy `.ansible.cfg` in user home
1. On `ansible-dev-ws`, launch `VS Code`, and open folder `~/ansible-examples`

1. On `ansible-dev-ws`, locate and copy `~/ansible-examples/ansible.cfg` file as `~/.ansible.cfg` or `/home/vagrant/.ansible.cfg`.

1. On `ansible-dev-ws`, launch `terminal`

1. On `ansible-dev-ws`, in `terminal`, if you do not have the `ansible-2.8.4` virtual environment activated, execute `source ~/py3venvironments/ansible-2.8.4/.env/bin/activate`. Otherwise skip this step.

1. On `ansible-dev-ws`, in `terminal`, execute `cd ~`, and then execute `ansible --version`

1. Read the output and see that Ansible searched and found the `.ansible.cfg` file in the user home. You should see `config file = /home/vagrant/.ansible.cfg`

#### Deploy `ansible.cfg` to current directory
1. On `ansible-dev-ws`, launch `terminal`, execute `cd ~/ansible-examples` and locate `ansible.cfg` file

1. On `ansible-dev-ws`, in `terminal`, execute `ansible --version`

1. Read the output and see that Ansible searched and found the `ansible.cfg` file in the current directory. You should see `config file = /home/vagrant/ansible-examples/ansible.cfg`

1. On `ansible-dev-ws`, in `terminal`, execute `cd ..`

1. On `ansible-dev-ws`, in `terminal`, execute `ansible --version`

1. Read the output and see that Ansible searched and found the `.ansible.cfg` file in the user home. You should see `config file = /home/vagrant/.ansible.cfg`

#### Set `ANSIBLE_CONFIG` environment variable
1. On `ansible-dev-ws`, launch `terminal`, execute `cd ~/ansible-examples` and locate `ansible.cfg` file

1. On `ansible-dev-ws`, in `terminal`, execute `cp ansible.cfg ANSIBLE.cfg`

1. On `ansible-dev-ws`, in `terminal`, execute `export ANSIBLE_CONFIG=~/ansible-examples/ANSIBLE.cfg`

1. On `ansible-dev-ws`, in `terminal`, execute `ansible --version`

1. Read the output and see that Ansible searched and found the `ANSIBLE.cfg` file. You should see `config file = /home/vagrant/ansible-examples/ANSIBLE.cfg`. *NOTE: Linux is case sensitive by default*.

## Inventory basics
Within this Ansible basics training we will only cover the basics of static hosts inventory. Just know that Ansible can merge multiple static inventory files. It can consume various dynamic inventories from various sources such as Hashicorp Consul. Moreover, if a dynamic inventory plugin doesn't exist you can construct your own plugin.

### ini style inventory structure
1. Read [Ansible User Guide: Working with Inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)

1. On `ansible-dev-ws`, in `VS Code`, open folder `~/ansible-examples` if it's not already opened

1. On `ansible-dev-ws`, in `VS Code`, locate and review `~/ansible-examples/hosts`. This is an example INI format hosts inventory file.

1. In the `hosts` file, identify the host groups, identify ungrouped hosts, identify variables

1. Test the use of the `hosts` file using the Ansible Adhoc command `ping`. On `ansible-dev-ws`, in `terminal`, execute `cd ~/ansible-examples`, then execute `ansible -i hosts --private-key=/home/vagrant/.ssh/vagrant_insecure_rsa -m ping all` to ping all hosts specified in this hosts inventory.

1. Test the use of the `hosts` file using the Ansible playbook `~/ ansible-examples/playbook-basics/linux-hosts/playbook-basics-01.yml`. This playbook simply pings hosts. On `ansible-dev-ws`, in `terminal`, execute `cd ~/ansible-examples`, then execute `ansible-playbook -i hosts --private-key=/home/vagrant/.ssh/vagrant_insecure_rsa playbook-basics/linux-hosts/playbook-basics-01.yml` to ping all hosts specified in this hosts inventory.

### YAML inventory structure

### Advanced YAML inventory structure

### Group and Host variables

*NOTE: If synonymn group and host variables exist in inventory and playbooks. The playbook variable value override the inventory value. It's best to formulate how you and where you manage your variables. There are valid use cases for managing variables in inventory and playbooks.*

## Adhoc Commands
Adhoc commands should have limited use. A valid use of an adhoc command is to ping all hosts or a subset of hosts. Another valid use might be to reboot or shutdown all hosts within a lab before leaving for a long weekend or holiday.

Examples of the most simple adhoc command is `ping`.

* `ansible -i hosts.yml --private-key=/home/vagrant/.ssh/vagrant_insecure_rsa -m ping all`

* `ansible -i hosts.yml --private-key=/home/vagrant/.ssh/vagrant_insecure_rsa -m ping centos-host1`

* `ansible -i hosts.yml --private-key=/home/vagrant/.ssh/vagrant_insecure_rsa -m ping centos-host2`

File transfer is another common use of adhoc commands. 

* `ansible webservers -i hosts.yml -m file -a "dest=/srv/foo/b.txt mode=600 owner=vagrant group=vagrant"`

Another use is shell commands such as reboot or shutdown of hosts.

* `ansible databases -i hosts.yml -a "/sbin/reboot" -f 10`

## Introduction to Playbooks
Playbooks are the basis for a really simple configuration management and multi-machine deployment system and one that is very well suited to deploying complex applications. Playbooks can declare configurations, but they can also orchestrate steps of any manual ordered process, even as different steps must bounce back and forth between sets of machines in particular orders. They can launch tasks synchronously or asynchronously.

### Playbook structure
Playbooks are expressed in YAML format and have a minimum of syntax, which intentionally tries to not be a programming language or script, but rather a model of a configuration or a process.

Each playbook is composed of one or more ‘plays’ in a list. The goal of a play is to map a group of hosts to some well defined roles, represented by things ansible calls tasks. At a basic level, a task is nothing more than a call to an ansible module.

By composing a playbook of multiple ‘plays’, it is possible to orchestrate multi-machine deployments, running certain steps on all machines in the webservers group, then certain steps on the database server group, then more commands back on the webservers group, etc.

*Example Playbook*
```
---
- hosts: webservers
  vars:
    http_port: 80
    max_clients: 200
  remote_user: root
  tasks:
  - name: ensure apache is at the latest version
    yum:
      name: httpd
      state: latest
  - name: write the apache config file
    template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf
    notify:
    - restart apache
  - name: ensure apache is running
    service:
      name: httpd
      state: started
  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted
```

### Playbooks in action

`cd /home/vagrant/ansible-basics-linux`
`ansible-playbook -i inventory/hosts.yml --private-key=/home/vagrant/.ssh/vagrant_insecure_rsa playbook-basics-01.yml`

## Ansible Modules

Modules are discrete units of code that can be used from the command line or in a playbook task. Documentation for each module can be accessed from the command line with the ansible-doc tool `ansible-doc {{ MODULE_NAME }}`. For example, `ansible-doc ping`.

For a list of all available modules, see [Ansible Modules Index](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html), or run `ansible-doc -l` in `terminal`.

## Roles

`cd /home/vagrant/ansible-inventory-basics`
`ansible-playbook -i inventory/hosts.yml --private-key=/home/vagrant/.ssh/vagrant_insecure_rsa main.yml`

## External References
### Ansible Configuration

* [Ansible Installation Guide: Configuring Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_configuration.html#configuration-file)

* [Github: ansible project - example `ansible.cfg`](https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg)

* [Ansible Documentation - Ansible Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#ansible-configuration-settings)

### Ansible Modules

* [Ansible Modules Index](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html)

### Ansible Adhoc Commands

* [Ansible Documentation: Introduction To Ad-Hoc Commands](https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html#file-transfer)

### Ansible Inventory

* [Ansible User Guide: Working with Inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)

### Ansible Playbooks

* [Ansible User Guide: Working with Playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html)

### Ansible Modules

* [Ansible User Guide: Working with Modules](https://docs.ansible.com/ansible/latest/user_guide/modules.html)

### YAML

* [Ansible Documentation: YAML Syntax](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html#yaml-syntax)

* [Wikipedia: YAML](https://en.wikipedia.org/wiki/YAML)

* [LearnXinYminutes.com: YAML](https://learnxinyminutes.com/docs/yaml/)

* [YAML.org: YAML Specification](https://yaml.org/spec/1.2/spec.html)

* [tutorialspoint.com: Ansible YAML Basics](https://www.tutorialspoint.com/ansible/ansible_yaml_basics.htm)



