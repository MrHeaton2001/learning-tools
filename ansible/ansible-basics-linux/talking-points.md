# Ansible Configuration Hierarchy

* Most settings that control Ansible's default behavior can be overridden via environment variables or configuation file called `ansible.cfg`

* Where is the `ansible.cfg` file
    * If Ansible is installed from a package manager such as Yum, the latest `ansible.cfg` should exist in `etc/ansible` path
    * If installed by `pip` or from source it's up to you to create `ansible.cfg`
        * I start with the example file available on Github https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg

* Ansible configuration search order
    * `ANSIBLE_CONFIG` (environment variable if set)
    * `ansible.cfg` (in the current directory)
    * `~/.ansible.cfg` (in the home directory)
    * `/etc/ansible/ansible.cfg`

*NOTE: The search process short circuits once the first file is found.*

*WARNING: Avoid security risks with `ansible.cfg` in the current directory. Set security so that the file is not world-writable!!!*

* With `ansible.cfg` many configuration options can accept relative paths; relative to the `ansible.cfg`

* SHOW config search order in action....


# Ansible Inventory

* Ansible looks for inventory in `/etc/ansible/hosts` or `/etc/ansible/hosts.yml|yaml` by default

* Hosts inventory can be managed as an INI file, YAML, TOML, etc.

* Inventory can be static (managed in files) or dynamic (managed in a database or key/value store such as Consul)

* We will focus on static inventory

* We will compare INI to YAML

* For production development we should use YAML; we will look at a more advanced inventory that is a simplified version of what is currently in production

* The hosts inventory must contain enough information that Ansible can use to successfully establish an SSH or WinRM connection to the host or hosts it is to control

* SHOW inventory examples in action....

# Ansible Adhoc Commands

* Ad hoc commands are commands which can be run individually to perform quick functions. These commands need not be performed later.

* Usecases for adhoc commands might include rebooting multiple hosts or copying files to or from multiple hosts

* The use of ad hoc commands should be thoughtful and minimal as they can cause configuration drift across hosts

* SHOW adhoc commands in action....

# Ansible Playbooks

* Playbooks are written in YAML. YAML is an acronym for `YAML Ain't Markup Language`. YAML is a superset of JSON.

* Playbooks provide Ansible with the plays and desired state you want the target host or hosts to exhibit

* Playbooks are executed from top to bottom

* Playbooks may contain one or more plays or tasks
