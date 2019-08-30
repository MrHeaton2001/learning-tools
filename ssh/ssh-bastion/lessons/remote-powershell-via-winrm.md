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

*NOTE: Because we are using a Windows 2019 Server Core vagrant box with OpenSSH, you can use `sftp -i vagrant_insecure_rsa  -P {{ LOCAL_PORT }} vagrant@localhost` to start an SFTP session on the Windows 2019 vagrant box. Once the SFTP session exists, execute `cd /to/remote/path/where/you/want/to/put/file` and then execute `put /local/path/to/file` to copy a local file to the Windows vagrant box.

In `dev-client`:

1. Launch Remmina
1. Start `remote5` RDP session
1. In your local `learning-tools` git repo, locate `create-domain.ps1` PowerShell script in `/ssh/ssh-bastion/scripts` path
1. In `remote5` RDP session, in PS terminal, execute the `create-domain.ps1` script
1. In `remote5` RDP session, in PS terminal, execute `Restart-Computer -Force`
1. Edit the `remote5` RDP profile. Add `example.net` in `Domain` and then `Save and Connect`
1. In your local `learning-tools` git repo, locate `add-external-dns-forwarder.ps1` PowerShell script in `learning-tools/ssh/ssh-bastion/scripts` path
1. In `remote5` RDP session, in PS terminal, execute the `add-external-dns-forwarder.ps1` script
1. In `remote5` RDP session, in PS terminal, execute `Get-Service adws,kdc,netlogon,dns` to verify successful installation and runtime status of AD-related services
1. In `remote5` RDP session, in PS terminal, execute `Get-ADDomainController` to view AD configuration details
1. In `remote5` RDP session, in PS terminal, execute `Get-ADDomain example.net` to view the details about `example.net` AD domain
1. In `remote5` RDP session, in PS terminal, execute `Get-ADForest example.net` to view the details about the AD forest
1. In `remote5` RDP session, in PS terminal, execute `Get-smbshare SYSVOL` to ensure the DC `SYSVOL` share is configured
1. In `remote5` RDP session, in PS terminal, execute `Get-ADUser -Identity vagrant -Properties *` to view all properties of `vagrant` user

*NOTE: Here's a handy link to all PowerShell ActiveDirectory commands https://docs.microsoft.com/en-us/powershell/module/addsadministration/?view=win10-ps.*

### Configure two Windows 2019 Servers on a private network (NOT domain-joined) to allow WinRM over HTTP

We will configure `remote3` and `remote6` to allow WinRM over HTTP between two Windows servers that are not joined to a domain. We will then validate the configuration.

#### Steps
On `dev-client`:

1. RDP to `remote3`
1. RDP to `remote6`
1. In `remote5` and `remote6` RDP sessions, Launch PowerShell terminal
1. In `remote5` and `remote6` RDP sessions, in PS terminal, execute `winrm enumerate winrm/config/Listener` to ensure WinRM over HTTP is configured
1. On both remote machines, ensure `WinRM-HTTP` inbound firewall rule exists and allows inbound requests over port `5985`
1. In `remote3` RDP session, in PowerShell terminal, execute `winrs -r:http://10.100.60.16:5985/wsman -u:vagrant -p:vagrant ipconfig` to attempt to connect to `remote6`
*NOTE: This WinRM connection should fail because the two servers on not domain joined. By default, servers not joined to a domain can only establish WinRM connections over HTTPS. You can overcome this issue by configuring TrustedHosts. 
1. In both RDP sessions, in Powershell, execute `Get-Item WSMan:\localhost\Client\TrustedHosts` to view the list of TrustedHosts. There should be no entries.
1. In both RDP sessions, execute `Set-Item WSMan:\localhost\Client\TrustedHosts -Value *` to allow all computers to connect
1. In `remote3` RDP session, in PowerShell terminal, execute `winrs -r:http://10.100.60.16:5985/wsman -u:vagrant -p:vagrant ipconfig` to attempt to connect to `remote6`. `ipconfig` should be executed on `remote6` via WinRM.
1. In `remote6` RDP session, in PowerShell terminal, execute `winrs -r:http://10.100.60.13:5985/wsman -u:vagrant -p:vagrant ipconfig` to attempt to connect to `remote3`.`ipconfig` should be executed on `remote3` via WinRM.
1. In `remote5` RDP session, in PowerShell terminal, execute `winrs -r:http://10.100.60.13:5985/wsman -u:vagrant -p:vagrant ipconfig` to attempt to connect to `remote3`. The WinRM connection should fail.
1. In `remote5` RDP session, execute `Set-Item WSMan:\localhost\Client\TrustedHosts -Value 10.100.60.13` to allow `remote5` to connect to `remote3`
e3`.
1. In `remote5` RDP session, in PowerShell terminal, execute `winrs -r:http://10.100.60.13:5985/wsman -u:vagrant -p:vagrant ipconfig` to attempt to connect to `remote3`. `ipconfig` should be executed on `remote3` via WinRM.
1. In `remote5` RDP session, in PowerShell terminal, execute `winrs -r:http://10.100.60.16:5985/wsman -u:vagrant -p:vagrant ipconfig` to attempt to connect to `remote6`. The WinRM connection should fail.
1. In all RDP sessions, execute `Clear-Item WSMan:\localhost\Client\TrustedHosts` to clear all entries from TrustedHosts list
1. Verify that all WinRM connection attempts fail.

### Configure two Windows 2019 Servers on a private network (NOT domain-joined) to allow WinRM over HTTPS

We will configure `remote3` and `remote6` to allow WinRM over HTTPS between two Windows servers that are not joined to a domain. We will then validate the configuration.

#### Steps

On `dev-client`:

1. In `remote3` and `remote6` RDP sessions, in PowerShell terminal, execute:
```
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -File $file
```
*NOTE: The `ConfigureRemotingForAnsible.ps1` script configures WinRM over HTTP and HTTPS, generates an X509 certificate that will be used to establish an encrypted WinRM session. Firewall rules are also modified so that WinRM over HTTP and HTTPS can be successfully established.*

2. Test WinRM over HTTP. In `remote3` RDP session, in PowerShell terminal, execute `winrs -r:http://10.100.60.16:5985/wsman -u:vagrant -p:vagrant ipconfig` to attempt to connect to `remote6`. The WinRM connection should fail.

3. Test out HTTPS. 2. Test WinRM over HTTP. In `remote3` RDP session, in PowerShell terminal, execute `winrs -r:http://10.100.60.16:5985/wsman -u:vagrant -p:vagrant -ssl ipconfig` to attempt to connect to `remote6`. The WinRM connection should fail because the certificate is not verifiable.

4. Test out HTTPS, ignoring certificate verification. The WinRM connection should succeed. In `remote3` RDP session, in PowerShell terminal, execute:
```
$username = "vagrant"
$password = ConvertTo-SecureString -String "vagrant" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

$session_option = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Invoke-Command -ComputerName 10.100.60.16 -UseSSL -ScriptBlock { ipconfig } -Credential $cred -SessionOption $session_option
```
5. Test out HTTPS, ignoring certificate verification. The WinRM connection should succeed. In `remote6` RDP session, in PowerShell terminal, execute:
```
$username = "vagrant"
$password = ConvertTo-SecureString -String "vagrant" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

$session_option = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Invoke-Command -ComputerName 10.100.60.13 -UseSSL -ScriptBlock { ipconfig } -Credential $cred -SessionOption $session_option
```

### Configure two Windows 2019 Servers on a private network that are domain-joined to allow WinRM over HTTP

Here's how to do this...don't do it. It has never and will never be a good idea to establish a WinRM connection over HTTP as information is transmitted in the clear. Now learn how to domain join two Windows 2019 Servers and configure to allow WinRM over HTTPS.

### Domain join two Windows 2019 Servers and configure to allow WinRM over HTTPS

We will domain join `remote3` and `remote6` to the `example.net` Active Directory domain and then configure WinRM to use an AD managed administrator account.

#### Steps

On `dev-client`:

1. In `remote3` RDP session, in Powershell terminal, execute `Get-NetIPConfiguration` to find the `InterfaceIndex` associated with the `10.100.60.13` IP address.

The output will look similar to the following:
```
InterfaceAlias       : Ethernet 2
InterfaceIndex       : 5
InterfaceDescription : Intel(R) PRO/1000 MT Desktop Adapter #2
NetProfile.Name      : Unidentified network
IPv4Address          : 10.100.60.13
IPv6DefaultGateway   :
IPv4DefaultGateway   :
DNSServer            : fec0:0:0:ffff::1
                       fec0:0:0:ffff::2
                       fec0:0:0:ffff::3
InterfaceAlias       : Ethernet
InterfaceIndex       : 3
InterfaceDescription : Intel(R) PRO/1000 MT Desktop Adapter
NetProfile.Name      : melaleuca.net
IPv4Address          : 10.0.2.15
IPv6DefaultGateway   :
IPv4DefaultGateway   : 10.0.2.2
DNSServer            : 10.0.2.3
```
In this example, the `InterfaceIndex` we are looking for is `5`.

2. In `remote3` RDP session, in Powershell terminal, execute `Set-DnsClientServerAddress -InterfaceIndex 5 -ServerAddresses 10.100.60.15` to set the DNS server `remote3` should use to resolve DNS names.

*NOTE: If `InterfaceIndex` value is not `5` you'll want to change it in the `Set-DnsClientServerAddress` command above.*

3. In `remote3` RDP session, in Powershell terminal, execute `Add-Computer -DomainName example.net -Credential vagrant@example.net` to join `remote3` to the `example.net` Active Directory domain.

4. In `remote3` RDP session, in Powershell terminal, execute `Restart-Computer -Force`.

5. Repeat steps 1 through 4 for `remote6`.

6. In `remote3` RDP session, in Powershell terminal, execute:
```
$username = "vagrant@example.net"
$password = ConvertTo-SecureString -String "vagrant" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

$session_option = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Invoke-Command -ComputerName remote6.example.net -UseSSL -ScriptBlock { ipconfig } -Credential $cred -SessionOption $session_option
```
This script will attempt to connect to `remote6` using the AD-managed user `vagrant@example.net`. This is an administrator user but it is not yet a local administrator on `remote6`. Expect this WinRM attempt to fail with an error similar to:

```
[remote6.example.net] Connecting to remote server remote6.example.net failed with the following error message : Access
is denied. For more information, see the about_Remote_Troubleshooting Help topic.
    + CategoryInfo          : OpenError: (remote6.example.net:String) [], PSRemotingTransportException
    + FullyQualifiedErrorId : AccessDenied,PSSessionStateBroken
```

The problem is that `vagrant@example.net` is not a local admin. We need to add `vagrant@example.net` to `remote6` as a local administrator with `Full Control`.

7. In `remote3` RDP session, in Powershell terminal, execute `Set-PSSessionConfiguration -ShowSecurityDescriptorUI -Name Microsoft.PowerShell -Force`.

8. In the `Permissions for ...` window, click `Add` and add `vagrant@example.net`. Click `Check Names`. Click `OK`. Tick the `Full Control`. Click `OK`.

9. In `remote3` RDP session, in Powershell terminal, execute:
```
$username = "vagrant@example.net"
$password = ConvertTo-SecureString -String "vagrant" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password

$session_option = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Invoke-Command -ComputerName remote6.example.net -UseSSL -ScriptBlock { ipconfig } -Credential $cred -SessionOption $session_option
```

Expect this WinRM connection attempt to succeed. You should see output similar to:
```
Windows IP Configuration


Ethernet adapter Ethernet:

   Connection-specific DNS Suffix  . : melaleuca.net
   Link-local IPv6 Address . . . . . : fe80::c1b8:2812:3945:d660%7
   IPv4 Address. . . . . . . . . . . : 10.0.2.15
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 10.0.2.2

Ethernet adapter Ethernet 2:

   Connection-specific DNS Suffix  . :
   Link-local IPv6 Address . . . . . : fe80::bdbe:cb8f:626:8368%5
   IPv4 Address. . . . . . . . . . . : 10.100.60.16
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . :
```

10. Repeat steps 6 through 9 for `remote6`.

## External References

### Windows 2019 Server
* [Windows Server Core: Start with PowerShell by default](https://sid-500.com/2018/12/11/windows-server-core-start-with-powershell-by-default/)

### Active Directory
* [Step-by-Step Guide to install Active Directory in Windows Server 2019 (PowerShell Guide)](http://www.rebeladmin.com/2018/10/step-step-guide-install-active-directory-windows-server-2019-powershell-guide/)

### PowerShell
* [PowerShell Module Browser](https://docs.microsoft.com/en-us/powershell/module/?view=win10-ps)
* [PowerShell Active Directory Module](https://docs.microsoft.com/en-us/powershell/module/addsadministration/?view=win10-ps)
* [Add computers to TrustedHosts list using PowerShell](https://www.dtonias.com/add-computers-trustedhosts-list-powershell/)
* [Remove computers from TrustedHosts List using PowerShell](https://social.technet.microsoft.com/Forums/scriptcenter/en-US/254407bb-7651-4b28-a655-b58221208ecb/powershell-remove-wsman-trustedhosts-value?forum=ITCG)

### WinRM
* [WinRM: Setting up a Windows Host for Ansible](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html)

### WinRM troubleshooting
* [StackOverflow.com: Cannot create remote powershell session after Enable-PSRemoting](https://stackoverflow.com/questions/16062033/cannot-create-remote-powershell-session-after-enable-psremoting?rq=1)