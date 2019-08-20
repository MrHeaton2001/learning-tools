# Establish a Remote Powershell Session
## Overview

The goals of this lesson are:

* Configure two Windows 2019 Servers on a private network (NOT domain-joined) to allow WinRM over HTTP
* Configure two Windows 2019 Servers on a private network (NOT domain-joined) to allow WinRM over HTTPS
* Configure two Windows 2019 Servers on a private network that are domain-joined to allow WinRM over HTTP
* Configure two Windows 2019 Servers on a private network that are domain-joined to allow WinRM over HTTPS

You will learn how to provision a Windows Domain Controller (DC; Active Directory and DNS) on Windows 2019 Server Core as a side affect of this training. In order to configure two domain-joined Windows 2019 Servers on a private network a DC must exist. You will also learn how to change a default behavior of Windows Server Core; By default, Windows Server 2019 starts with `cmd` rather than Powershell. We will configure each server to use Powershell by default.

## Prerequisites

* Fetch the most up-to-date learning-tools assets. Execute `git pull`.
* Fetch the Fedora development workstation vagrant box as described in [Add new client to public network](add-new-client-to-public-network.md)
* Fetch a Windows 2016 Server Standard (with Desktop Experience) vagrant box. Execute `vagrant box add peru/windows-server-2016-standard-x64-eval --box-version 20190801.01`.
* Fetch a Windows 2019 Server Standard Core vagrant box. Execute `vagrant box add gusztavvargadr/windows-server --box-version 1809.0.1907-standard-core`.
* On the Fedora development workstation, configure RDP profiles for `remote4` and `remote6` in `Remmina` as described [RDP to Remote Windows Server](rdp-to-remote-windows-node.md).

## Lesson
### Vagrant Virtual Data Center (VDC) setup

For this WinRM lesson we will start the `dev-client` (Fedora development workstation), `bastion` (CentOS Bastion Host), `remote3` (Windows 2019 Server), `remote5` (Windows 2019 Server Core), and `remote6` (another Windows 2019 Server) Vagrant boxes. From `dev-client`, we'll establish an RDP session to `remote3`, `remote5`, and `remote6` through `bastion`. We will also provision `remote5` as a Domain Controller (DC). The DC will be used later in the lesson.

*NOTE: We could take an easier approach by connecting to each Windows 2016 Server through the VirtualBox GUI emulation but this path would not simulate managing servers in an enterprise.*

#### Steps
##### Instantiate the Vagrant VDC

1. Navigate to `ssh/ssh-bastion` path in `learning-tools` project.
1. Ensure metadata entries in `machines.yml` are uncommented for `dev-client`, `bastion`, `remote3`, `remote5`, and `remote6` vagrant boxes.
1. Start the required vagrant boxes.
    * `vagrant up dev-client`
    * `vagrant up bastion`
    * `vagrant up remote3`
    * `vagrant up remote5`
    * `vagrant up remote6`

##### Configure RDP profiles in Remmina

We will create RDP profiles for `remote3`, `remote5`, and `remote6`. If you have already created RDP profiles for each of these boxes you can skip this section. Each profile will be mapped to a unique local port so that you can have concurrent active RDP sessions.

In `dev-client`:

1. Launch `Remmina`
1. Create a new profile
1. In the `Remmina Desktop Preference` window, enter `remote3 (Win2019 Vagrant VirtualBox)` in `Name`, `vagrant boxes` in `Group`, `RDP` in `Protocol`, `/home/vagrant/rdp-tunnel.sh start 33388 3389 10.100.60.13 bastion` in `Pre Command`, `/home/vagrant/rdp-tunnel.sh stop 33388 3389 10.100.60.13 bastion` in `Post Command`, `localhost:33388` in `Server`, `vagrant` in `User name`, `vagrant` in `User Password`, and finally click `Save and Connect` button. Expect a RDP Session window. You should now have an active RDP session to `remote3`.
1. Create a new profile
1. In the `Remmina Desktop Preference` window, enter `remote5 (Win2019 Core Vagrant VirtualBox)` in `Name`, `vagrant boxes` in `Group`, `RDP` in `Protocol`, `/home/vagrant/rdp-tunnel.sh start 33390 3389 10.100.60.15 bastion` in `Pre Command`, `/home/vagrant/rdp-tunnel.sh stop 33390 3389 10.100.60.15 bastion` in `Post Command`, `localhost:33390` in `Server`, `vagrant` in `User name`, `vagrant` in `User Password`, and finally click `Save and Connect` button. Expect a RDP Session window. You should now have an active RDP session to `remote5`.
1. Create a new profile
1. In the `Remmina Desktop Preference` window, enter `remote6 (Win2019 Core Vagrant VirtualBox)` in `Name`, `vagrant boxes` in `Group`, `RDP` in `Protocol`, `/home/vagrant/rdp-tunnel.sh start 33389 3389 10.100.60.16 bastion` in `Pre Command`, `/home/vagrant/rdp-tunnel.sh stop 33389 3389 10.100.60.16 bastion` in `Post Command`, `localhost:33389` in `Server`, `vagrant` in `User name`, `vagrant` in `User Password`, and finally click `Save and Connect` button. Expect a RDP Session window. You should now have an active RDP session to `remote6`.

##### Configure SSH profiles in .ssh/config

We will create SSH profiles in `.ssh/config` for `remote3`, `remote5`, and `remote6`.

In `dev-client`:

1. Launch `terminal`
1. `vi ~/.ssh/config`
1. Change contents of `config` and save changes
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

# Windows 2019 Server with OpenSSH configured
Host remote3
  Hostname 10.100.60.13
  IdentityFile ~/.ssh/vagrant_insecure_rsa
  ProxyCommand ssh bastion -W %h:%p

# Windows 2019 Server Core with OpenSSH configured
Host remote5
  Hostname 10.100.60.15
  IdentityFile ~/.ssh/vagrant_insecure_rsa
  ProxyCommand ssh bastion -W %h:%p

# Windows 2019 Server with OpenSSH configured
Host remote6
  Hostname 10.100.60.16
  IdentityFile ~/.ssh/vagrant_insecure_rsa
  ProxyCommand ssh bastion -W %h:%p
```

*NOTE: To escape from Insert mode in vim in a VirtualBox machine, you can use `CTRL+C` instead of `ESC`. It's probably a better habit to use `CTRL+C` anyway as `ESC` is very far away and it's use stemmed from an ancient requirement that is not longer valid.*

##### Verify SSH connectivity

In `dev-client`:

1. Launch `terminal`
1. `ssh remote3`
1. `whoami`
1. `hostname`
1. `exit`
1. `ssh remote5`
1. `whoami`
1. `hostname`
1. `exit`
1. `ssh remote6`
1. `whoami`
1. `hostname`
1. `exit`

##### Configure Windows 2019 Server Core to start Powershell by Default

In `dev-client`:

1. Launch Remmina
1. Start `remote5` RDP session
1. In RDP session, in `CMD.exe` window, execute `powershell`
1. Execute `Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\' -Name Shell -Value 'powershell.exe'`
1. In `CMD.exe` window, execute `Restart-Computer -Force`
1. Start `remote5` RDP session
1. Notice that Powershell starts rather than CMD

##### Provision Windows 2019 Server Core as a Domain Controller

We will provision `remote5`, the Windows 2019 Server Core machine, as a DC. This requires installation and configuration of Active Directory and DNS. When this process is complete we will have an Active Directory server for `example.net` and a DNS server configured with an external DNS forwarder.

In `dev-client`:

1. Launch Remmina
1. Start `remote5` RDP session
1. In your local `learning-tools` git repo, locate `create-domain.ps1` PowerShell script in `/ssh/ssh-bastion/scripts` path
1. In PS terminal, execute script
1. In PS terminal, execute `Restart-Computer -Force`
1. Edit the `remote5` RDP profile. Add `example.net` in `Domain` and then `Save and Connect`
1. In your local `learning-tools` git repo, locate `add-external-dns-forwarder.ps1` PowerShell script in `learning-tools/ssh/ssh-bastion/scripts` path
1. In PS terminal, execute script
1. In PS terminal, execute `Get-Service adws,kdc,netlogon,dns` to verify successful installation and runtime status of AD-related services
1. Execute `Get-ADDomainController` to view AD configuration details
1. Execute `Get-ADDomain example.net` to view the details about `example.net` AD domain
1. Execute `Get-ADForest example.net` to view the details about the AD forest
1. Execute `Get-smbshare SYSVOL` to ensure the DC `SYSVOL` share is configured
1. Execute `Get-ADUser -Identity vagrant -Properties *` to view all properties of `vagrant` user

*NOTE: Here's a handy link to all PowerShell ActiveDirectory commands https://docs.microsoft.com/en-us/powershell/module/addsadministration/?view=win10-ps.*
### Configure two Windows 2019 Servers on a private network (NOT domain-joined) to allow WinRM over HTTP

We will configure `remote3` and `remote6` to allow WinRM over HTTP and validate the configuration.




## External References

### Windows 2019 Server
* [Windows Server Core: Start with PowerShell by default](https://sid-500.com/2018/12/11/windows-server-core-start-with-powershell-by-default/)

### Active Directory
* [Step-by-Step Guide to install Active Directory in Windows Server 2019 (PowerShell Guide)](http://www.rebeladmin.com/2018/10/step-step-guide-install-active-directory-windows-server-2019-powershell-guide/)

### PowerShell
* [PowerShell Module Browser](https://docs.microsoft.com/en-us/powershell/module/?view=win10-ps)
* [PowerShell Active Directory Module](https://docs.microsoft.com/en-us/powershell/module/addsadministration/?view=win10-ps)

### WinRM troubleshooting
* [StackOverflow.com: Cannot create remote powershell session after Enable-PSRemoting](https://stackoverflow.com/questions/16062033/cannot-create-remote-powershell-session-after-enable-psremoting?rq=1)