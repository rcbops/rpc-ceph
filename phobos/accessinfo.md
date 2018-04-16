## RPC PHOBOS lab

This lab has a complete Openstack Enviornment with several dedicated OnMetal boxes built to certain RPC product specifications.  


### Add a New User

Get the project *ID*
 * Storage Engineers are placed in the rpc-storage-project
 * Service Delivery Engineers are placed tin the rpc-storage-support-project
```
 $ openstack project list
+----------------------------------+-----------------------------+
| ID                               | Name                        |
+----------------------------------+-----------------------------+
| 5714f057a500416da26acd464f93efc7 | rpc-storage-project         |
| fe014111d6b04e27b2196da54cb24bfc | rpc-storage-support-project |
+----------------------------------+-----------------------------+
```

*Be sure to run the next two commands with a Domain Scope Token*

Creeate User
```
$ openstack user create --domain 5406855310964adeac58c82f7e58d6fd --project fe014111d6b04e27b2196da54cb24bfc  --password changeme --email <email address> <user name>
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| default_project_id  | fe014111d6b04e27b2196da54cb24bfc |
| domain_id           | 5406855310964adeac58c82f7e58d6fd |
| email               | username@example.com             |
| enabled             | True                             |
| id                  | c23d7b885a4948248b82ae3397e9d863 |
| name                | username                         |
| password_expires_at | None                             |
+---------------------+----------------------------------+
```

Add Role
```
openstack role add --project fe014111d6b04e27b2196da54cb24bfc   --user c23d7b885a4948248b82ae3397e9d863 _member_
```

Sample openrc File
Set the correct values for:
 * OS_USERNAME
 * OS_PROJECT_NAME
 * OS_TENANT_NAME
```
export LC_ALL=C

# COMMON CINDER ENVS
export CINDER_ENDPOINT_TYPE=internalURL

# COMMON NOVA ENVS
export NOVA_ENDPOINT_TYPE=internalURL

# COMMON OPENSTACK ENVS
export OS_ENDPOINT_TYPE=internalURL
export OS_INTERFACE=internalURL
export OS_USERNAME=<user name>
export OS_PASSWORD=changeme
export OS_PROJECT_NAME=<rpc-storage-support-project or rpc-storage-project>
export OS_TENANT_NAME=<rpc-storage-support-project or rpc-storage-project>
export OS_AUTH_URL=http://172.20.4.10:5000/v3
export OS_NO_CACHE=1
export OS_USER_DOMAIN_NAME=rpc-storage-domain
export OS_PROJECT_DOMAIN_NAME=rpc-storage-domain
export OS_REGION_NAME=RegionOne

# For openstackclient
export OS_IDENTITY_API_VERSION=3
export OS_AUTH_VERSION=3
```

### PHOBOS VPN

For information on this VPN contact
 * Shannon Mitchell - shannon.mitchell@rackspace.com
 * Keith Fralick - keith.fralick@rackspace.com


### Phobos Horizon EndPoint:   

https://172.20.4.10/


### Accessing the Phobos Environment

At the very least, you should start out with a domain, username, password, tenant and at least 1 floating ip tied to a nat.  
The user will be a domain admin. With this you should be able to log into horizon and create your own project members.


### Floating IP NAT Mappings



We will start by assiging 1 floating ip to the tenant that has a NAT set up.  This falls
outside of the dhcp range in the ironic network to keep them from conflicting with general
floating ip's pulled from the public ironic network.  The instance will only be accessible from
the bastion servers once a floating ip with NAT has been assigned to it.  The public
addresses for these will not be viewable from openstack, so I'm providing the mappings here.


Floating IP     | Public Nat      
--------------- | ----------
172.20.40.122   | 207.97.197.128 
172.20.40.123   | 207.97.197.129 
172.20.40.124   | 207.97.197.130 
172.20.40.125   | 207.97.197.131 
172.20.40.126   | 207.97.197.132 
172.20.40.127   | 207.97.197.133 
172.20.40.128   | 207.97.197.134 
172.20.40.129   | 207.97.197.135 



### User Management

At the start, we will create 1 admin user for each project(ex: projectname-admin).  This is a domain user in a multi-domain configuration.  You will be able
to create your own projects and users with this.  Please do not make any major changes that could cause issues with other tenants without running it through 
#rpc-eng-ops.  If something does happen that causes a major outage, don't be suprised if you are asked to run an RCA session with the other projects to make 
sure everyone knows what could go wrong :) 
