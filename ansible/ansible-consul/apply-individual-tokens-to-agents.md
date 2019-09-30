https://learn.hashicorp.com/consul/security-networking/production-acls#apply-individual-tokens-to-agents

## Apply Individual Tokens to Agents

* Create per agent policy
* Create the agent token (Create token with the newly created agent policy)
* Add the token to the agent


```
[vagrant@centos7-host6 ~]$ mkdir consul-policy-assets
[vagrant@centos7-host6 ~]$ cd consul-policy-assets/
[vagrant@centos7-host6 consul-policy-assets]$ export CONSUL_HTTP_TOKEN="a2006dd0-36f3-4413-a298-62777f342746"
[vagrant@centos7-host6 consul-policy-assets]$ vi consul1-policy.hcl
[vagrant@centos7-host6 consul-policy-assets]$ vi consul2-policy.hcl
[vagrant@centos7-host6 consul-policy-assets]$ vi consul3-policy.hcl
[vagrant@centos7-host6 consul-policy-assets]$ vi centos7-host1-policy.hcl
[vagrant@centos7-host6 consul-policy-assets]$ vi ansible-dev-ws-policy.hcl


[vagrant@centos7-host6 consul-policy-assets]$ consul acl policy create \
> -name consul1 \
> -rules @consul1-policy.hcl
ID:           2a7fb1f1-bead-3fab-ccb6-aeba7fac7a30
Name:         consul1
Description:  
Datacenters:  
Rules:
# consul1-policy.hcl
node "consul1" {
  policy = "write"
}

[vagrant@centos7-host6 consul-policy-assets]$ consul acl policy create \
> -name consul2 \
> -rules @consul2-policy.hcl
ID:           016507ca-3c7e-9559-0c2a-be12f7075aa7
Name:         consul2
Description:  
Datacenters:  
Rules:
# consul2-policy.hcl
node "consul2" {
  policy = "write"
}

[vagrant@centos7-host6 consul-policy-assets]$ consul acl policy create \
> -name consul3 \
> -rules @consul3-policy.hcl
ID:           953cbdd3-5fa8-ae8d-fa2f-09f162128113
Name:         consul3
Description:  
Datacenters:  
Rules:
# consul3-policy.hcl
node "consul3" {
  policy = "write"
}

[vagrant@centos7-host6 consul-policy-assets]$ consul acl policy create \
> -name centos7-host1 \
> -rules @centos7-host1-policy.hcl
ID:           465ade1e-abbf-7408-f24a-a0a2b41c2aa5
Name:         centos7-host1
Description:  
Datacenters:  
Rules:
# centos7-host1-policy.hcl
node "centos7-host1" {
  policy = "write"
}

[vagrant@centos7-host6 consul-policy-assets]$ ^C
[vagrant@centos7-host6 consul-policy-assets]$ consul acl policy create \
> -name ansible-dev-ws \
> -rules @ansible-dev-ws-policy.hcl
ID:           c0fed046-4de5-2c06-4acc-e3cc1f369c61
Name:         ansible-dev-ws
Description:  
Datacenters:  
Rules:
# ansible-dev-ws-policy.hcl
node "ansible-dev-ws" {
  policy = "write"
}



[vagrant@centos7-host6 consul-policy-assets]$ consul acl token create \
> -description "consul1 agent token" \
> -policy-name consul1
AccessorID:       2b3f8034-ae7a-f7d8-71a0-a6488d9e1802
SecretID:         3c2966bf-8072-8265-3c34-02cfd53bb7fd
Description:      consul1 agent token
Local:            false
Create Time:      2019-09-13 21:48:09.984720234 +0000 UTC
Policies:
   2a7fb1f1-bead-3fab-ccb6-aeba7fac7a30 - consul1
[vagrant@centos7-host6 consul-policy-assets]$ consul acl token create \
> -description "consul2 agent token" \
> -policy-name consul2
AccessorID:       e7f29858-d5b0-faa6-0794-36f36c62eaf7
SecretID:         224a1b8f-05c1-e49b-4f03-893f6314fb85
Description:      consul2 agent token
Local:            false
Create Time:      2019-09-13 21:48:28.259685003 +0000 UTC
Policies:
   016507ca-3c7e-9559-0c2a-be12f7075aa7 - consul2
[vagrant@centos7-host6 consul-policy-assets]$ consul acl token create \
> -description "consul3 agent token" \
> -policy-name consul3
AccessorID:       904d8cf5-b40a-8fae-774e-dc9afca59aba
SecretID:         a7166c3f-f943-2b95-46e1-3baa997a231a
Description:      consul3 agent token
Local:            false
Create Time:      2019-09-13 21:48:48.335508206 +0000 UTC
Policies:
   953cbdd3-5fa8-ae8d-fa2f-09f162128113 - consul3
[vagrant@centos7-host6 consul-policy-assets]$ consul acl token create \
> -description "centos7-host1 agent token" \
> -policy-name centos7-host1
AccessorID:       f39432da-d9c0-cb76-4ab7-bccc2ecd0cc7
SecretID:         193569e3-d935-5dd2-dd7b-6fde95218b13
Description:      centos7-host1 agent token
Local:            false
Create Time:      2019-09-13 21:49:04.951967668 +0000 UTC
Policies:
   465ade1e-abbf-7408-f24a-a0a2b41c2aa5 - centos7-host1
[vagrant@centos7-host6 consul-policy-assets]$ consul acl token create \
> -description "ansible-dev-ws agent token" \
> -policy-name ansible-dev-ws
AccessorID:       96fc0b21-1c67-58a5-c557-19eab3a54ac5
SecretID:         ab69e373-ec94-97f3-6dab-5372f013f343
Description:      ansible-dev-ws agent token
Local:            false
Create Time:      2019-09-13 21:49:26.279096425 +0000 UTC
Policies:
   c0fed046-4de5-2c06-4acc-e3cc1f369c61 - ansible-dev-ws


   
[vagrant@centos7-host6 consul-policy-assets]$ consul acl set-agent-token agent 3c2966bf-8072-8265-3c34-02cfd53bb7fd
ACL token "agent" set successfully
[vagrant@centos7-host6 consul-policy-assets]$ consul acl set-agent-token agent 224a1b8f-05c1-e49b-4f03-893f6314fb85
ACL token "agent" set successfully
[vagrant@centos7-host6 consul-policy-assets]$ consul acl set-agent-token agent a7166c3f-f943-2b95-46e1-3baa997a231a
ACL token "agent" set successfully
[vagrant@centos7-host6 consul-policy-assets]$ consul acl set-agent-token agent 193569e3-d935-5dd2-dd7b-6fde95218b13
ACL token "agent" set successfully
[vagrant@centos7-host6 consul-policy-assets]$ consul acl set-agent-token agent ab69e373-ec94-97f3-6dab-5372f013f343
ACL token "agent" set successfully

```