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
### Configure two Windows 2016 Servers on a private network (NOT domain-joined) to allow WinRM over HTTP

For this lesson we will start the `dev-client` (Fedora development workstation), `bastion` (CentOS Bastion Host), `remote4` (Windows 2016 Server), and `remote6` (another Windows 2016 Server) Vagrant boxes. From `dev-client`, we'll establish an RDP session to `remote3` and `remote6` through `bastion`. Finally we will configure `remote3` and `remote6` to allow WinRM over HTTP and validate the configuration.

*NOTE: We could take an easier approach by connecting to each Windows 2016 Server through the VirtualBox GUI emulation but this path would not simulate managing servers in an enterprise.*

#### Steps

1. Navigate to `ssh/ssh-bastion` path in `learning-tools` project.
1. Ensure metadata entries in `machines.yml` are uncommented for `dev-client`, `bastion`, `remote3`, and `remote6` vagrant boxes.
1. Start the required vagrant boxes.
    * `vagrant up dev-client`
    * `vagrant up bastion`
    * `vagrant up remote3`
    * `vagrant up remote6`
1. test



## External References

### Windows 2019 Server
* [Windows Server Core: Start with PowerShell by default](https://sid-500.com/2018/12/11/windows-server-core-start-with-powershell-by-default/)

### WinRM troubleshooting
* [StackOverflow.com: Cannot create remote powershell session after Enable-PSRemoting](https://stackoverflow.com/questions/16062033/cannot-create-remote-powershell-session-after-enable-psremoting?rq=1)