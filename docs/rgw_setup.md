# Setting up Ceph Object Gateway for different RPC Use Cases

Ceph Object Gateway(rgw) is an object storage interface built on top of librados to provide applications with a RESTful gateway to Ceph Storage Clusters. Ceph Object Storage supports two interfaces  S3 and OpenStack Swift.   

Complete documentation for the Ceph Object Gateway can be found (here.)[http://docs.ceph.com/docs/master/radosgw/]

## Role of rpc-ceph
The purpose of (rpc-ceph)[https://github.com/rcbops/rpc-ceph] is to provide a consistant versioned set of processes, variables and versioned software for RPC's use.  

### List of Use Cases

* General Installation using ceph-ansible without integration to an Auth System
* Configuring rgw to use an instance of OpenStack Keystone


## Installation of rgw without Integration to an Auth System
To Install rgw and use the radosgw_keystone variables set to ceate a user/password you can use to access this sthem

### To install rgw addtions to the inventory file.   

Add the **rgws** group with a list of hosts into the ceph environment's inventory file. 
For example:
```bash
[rgws]
ceph-rgw01
ceph-rgw02
ceph-rgw03
```
**Special Note**: You will need to have access to the keystone host/container via ssh, from the deployment host


### Preset variables
rpc-ceph has already assigned some ceph-ansible variable in the file **(playbooks/group_vars/rgws.yml)[https://raw.githubusercontent.com/rcbops/rpc-ceph/master/playbooks/group_vars/rgws.yml]**  If special needs are required for a specific customer's requirements these variable can be changed or overridden

### Make sure you have each of these variables set in your vars file
* public_network
* internal_lb_vip_address
* service_region
* radosgw_keystone_admin_user
* radosgw_keystone_admin_password
* radosgw_keystone_admin_tenant

### Run the deployment
```bash
ceph-ansible -i <link to your inventory file> playbooks/deploy-ceph.yml -e@<link to your vars file>
```


## Installation of rgw with Openstack KeyStone and OpenStack Ansible
To Install rgw and connect it to a Stand Alone instance of OpenStack Keystone.   Please refer to other documentation for the RPC guidelines for installing and setting up OpenStack Keystone.   This ceph rgw guide assumes you have an working OpenStack Keystone system in set up set up because you will need information from it for variables

### To install rgw addtions to the inventory file.   

Add the **rgws** group with a list of hosts into the ceph environment's inventory file. 
For example:
```bash
[rgws]
ceph-rgw01
ceph-rgw02
ceph-rgw03

[keystone_all]
keystone_host   ansible_host=<ip_address>
```
**Special Note**: You will need to have access to the keystone host/container via ssh, from the deployment host

### Preset variables
rpc-ceph has already assigned some ceph-ansible variable in the file **(playbooks/group_vars/rgws.yml)[https://raw.githubusercontent.com/rcbops/rpc-ceph/master/playbooks/group_vars/rgws.yml]**  If special needs are required for a specific customer's requirements these variable can be changed or overridden

### Make sure you have each of these variables set in your vars file
* public_network
* internal_lb_vip_address
* service_region
* radosgw_keystone **(set to True)**
* radosgw_keystone_admin_user
* radosgw_keystone_admin_password
* radosgw_keystone_admin_tenant
These all need to match whatever was setup on the openstack side, so the password/admin_user/tenant
all have to match what is in the keystone/openstack deployment.
* keystone_admin_user_name
* keystone_auth_admin_password
* keystone_admin_tenant_name
* keystone_service_adminuri_insecure

### Run the deployment
```bash
ceph-ansible -i <link to your inventory file> playbooks/deploy-ceph.yml -e@<link to your vars file>
```


## Load Balancers and SSL Certs
A load balancer should be deployed prior to ceph rgw install and you have VIP.  Currently RPC terminates SSL in the load balancer so the Ceph Object Store does not need anything for SSL set.

F5:  ?

HAProxy:
This is a bit tricky since we don't have IP/containers to point to. I'd advise against creating the swift group and then just not deploying it, because we (a) don't want the containers for swift at all, and (b) don't want them in the inventory. The haproxy group would have to be slightly different anyway (healthcheck wise etc).
In the last deploy we created a dummy group for ceph in /etc/openstack_deploy/env.d/ and then added some "cephrgw" hosts to a group, for the purposes of haproxy - this is probably the best way to go about it for haproxy right now, I've put a patch upstream to allow us to manually specify ip address info for haproxy endpoints (https://review.openstack.org/#/c/527847/) but I'm trying to get that backported.
Lastly, create the appropriate vars for Ceph:
Something like this: https://review.openstack.org/#/c/517856/8/group_vars/ceph-rgw.yml



