# Bastion Hosts
## Overview
Bastion hosts, also known as jump boxes, act as a proxy allowing a client to connect to remote servers. These remote servers are generally on a private subnet that is not directly accessible. The bastion is most often on a public subnet.

When a client wants to connect to a remote server in the private subnet it must use a bastion host in the same network as a proxy to establish the connection to the target remote server.

## Benefits of bastion hosts

The benefits of bastion hosts are:

* Single point for logins in the network (or subnet). This simplifies and centralizes firewall rules
* Easy to log all access and actions
* Improves security of authentication

## Limitations of bastion hosts

The limitations of bastion hosts are:

* Accessing applications running on remote servers in a private network is limited to dev/test scenarios; this is not a production solution
* Access to private resources through a bastion host is generally too complicated for the average business user; VPNs are generally employed for business users