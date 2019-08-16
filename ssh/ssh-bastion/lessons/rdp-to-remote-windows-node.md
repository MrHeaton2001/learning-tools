# RDP to remote Windows Server
## Overview

The goals of this lesson are:

* RDP to a remote Windows 2016 Server on a private network through a SSH tunnel

More specifically we will learn how to configure Remmina to establish the SSH tunnel, establish the RDP session, and stop the SSH tunnel when RDP session is stopped.

## Prerequisites

* You added the Fedora development workstation client to the Vagrant network as described in [Add new client to public network](add-new-client-to-public-network.md)

The Fedora development workstation is provisioned with [Remmina Remote Desktop Client](https://remmina.org/). Remmina will be used extensively in this lesson.

## Lesson
### Basic approach to RDP through a SSH tunnel

We will start the `dev-client` (Fedora development workstation), `bastion` (CentOS Bastion Host), and `remote4` (Windows 2016 Server) Vagrant boxes. Next, we'll establish an SSH tunnel in `terminal` and create an RDP session through the SSH tunnel using Remmina. Finally, we'll stop the SSH tunnel.

#### Steps

1. Navigate to `ssh/ssh-bastion` path in the `learning-tools` project

1. Start Fedora development workstation. Execute `vagrant up dev-client`

1. Start bastion host. Execute `vagrant up bastion`

1. Start remote Windows 2016 server. Uncomment `remote4` entry in `machines.yml` file and save changes. Execute `vagrant up remote4`

1. On `dev-client`, launch `terminal`. 

1. Establish SSH tunnel to remote Windows 2016 server. In `terminal`, execute `ssh -L 33389:10.100.60.14:3389 bastion -N`. *NOTE: `ssh -L {{ LOCAL_PORT }}:{{ RDP_NODE_IP_OR_FQDN }}:{{ RDP_NODE_PORT }} {{ BASTION_HOST_IP_OR_FQDN }} -N` is mapping an unused local port to the remote port of the remote Windows server and establishing the SSH tunnel through the specified bastion host.*

1. On `dev-client`, launch `remmina`.

1. In `remmina`, type `localhost:33389` in RDP textbox and ENTER. A new Remmina window for `localhost:33389` is instantiated.

1. In the `localhost:33389` Remmina window, enter `vagrant` for the User name and Password and click `OK`. A RDP Session window for `remote4` is instantiated.

1. Verify that you have RDP'd to the correct server. In the RDP window, launch PowerShell.

1. In PowerShell, execute `ifconfig`. You expect to see `10.100.60.14` as one of the addresses. Execute `hostname`. You expect to see `remote4`. Execute `whoami`. You expect to see `remote4\vagrant`.

### Stop SSH Tunnel

While the RDP session is active, we will stop the SSH tunnel to prove that the RDP session is in fact running in the tunnel.

1. On `dev-client`, in the terminal session in which the SSH tunnel is running, `CTRL-C`. The tunnel is destroyed and The RDP session is terminated. In the Remmina RDP session window, you will see the message "Reconnection in progress. Attempt N of 20...".

1. In `terminal`, up arrow and ENTER to start the SSH tunnel again. See that the RDP session is restablished.

1. Disconnect or close all Remmina windows and stop the SSH tunnel.

### Elegant approach to RDP through a SSH tunnel

Now that you know how to establish an RDP session through a SSH tunnel, we will improve the solution and improve reuse. We will create a shell script that starts and stops SSH tunnels. Remmina will execute this script in pre and post processes when establishing and destroying RDP sessions.

The script accepts five parameters:

* `$1` - `start` or `stop`
* `$2` - local port (must not be in use; `33389` for example) to be mapped to the RDP node port (normally `3389`)
* `$3` - RDP node port (normally `3389`)
* `$4` - RDP node IP or FQDN (`10.100.60.14` for example)
* `$5` - Bastion Host IP or FQDN; if the `.ssh/config` file contains an entry for `bastion` then we can use `bastion` as the parameter value

The script is named `rdp-tunnel.sh`. It is located in `ssh/ssh-bastion`.

#### Steps
1. Copy `rdp-tunnel.sh` to `dev-client`. Put this file in `/home/vagrant`.

1. On `dev-client`, change security on `rdp-tunnel.sh`. In `terminal`, execute `chmod +x /home/vagrant/rdp-tunnel.sh`.

1. On `dev-client`, launch `Remmina`.

1. In `Remmina`, create a new connection profile. Click the button in the top, left corner of the `Remmina Remote Desktop Client` window.

1. In the `Remmina Desktop Preference` window, enter `remote4 (Win2016 VirtualBox)` in `Name`, `vagrant boxes` in `Group`, `RDP` in `Protocol`, `/home/vagrant/rdp-tunnel.sh start 33388 3389 10.100.60.14 bastion` in `Pre Command`, `/home/vagrant/rdp-tunnel.sh stop 33388 3389 10.100.60.14 bastion` in `Post Command`, `localhost:33388` in `Server`, `vagrant` in `User name`, `vagrant` in `User Password`, and finally click `Save and Connect` button. Expect a RDP Session window. You should now have an active RDP session to `remote4`.

1. On `dev-client`, in `terminal`, execute `ps aux |grep "ssh -M"`. Expect to see a ssh process running.

1. In `Remmina`, in the RDP Session window, click the `Disconnect` button

1. In `terminal`, execute `ps aux |grep "ssh -M"`. Expect to not find the ssh process as it was destroyed during the Post Command execution.

## External References