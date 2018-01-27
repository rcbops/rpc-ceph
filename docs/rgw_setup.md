# Setting up Ceph Object Gateway for different RPC Use Cases

Ceph Object Gateway(rgw) is an object storage interface built on top of librados to provide applications with a RESTful gateway to Ceph Storage Clusters. Ceph Object Storage supports two interfaces  S3 and OpenStack Swift.

Complete documentation for the Ceph Object Gateway can be found (here.)[http://docs.ceph.com/docs/master/radosgw/]

## Role of rpc-ceph
The purpose of (rpc-ceph)[https://github.com/rcbops/rpc-ceph] is to provide a consistant versioned set of processes, variables and software for RPC's use.

### List of Use Cases

* General Installation using ceph-ansible **without** active integration to an Auth System
* General Installation using ceph-ansible **with** active integration to an Auth System


## Installation of radosgw to integrate with an external keystone auth system.
Please refer to other documentation for the RPC guidelines for installing and setting up OpenStack Keystone.
We will need to pull the `user`, `tenant` and `password` for the user we wish to tie in with.

### To install rgw addtions to the inventory file.

Add the **rgws** group with a list of hosts into the ceph environment's inventory file.
For example:

```bash
[rgws]
ceph-rgw01
ceph-rgw02
ceph-rgw03
```

### Preset variables
RPC-ceph has already assigned some ceph-ansible variables in **(playbooks/group_vars/rgws.yml)[https://raw.githubusercontent.com/rcbops/rpc-ceph/master/playbooks/group_vars/rgws.yml]**

If you need to override ceph.conf variables use the `ceph_conf_overrides_extra` variable hash within your vars file.

### These variables are required to be populated.
* public\_network
* internal\_lb\_vip\_address
* service\_region
* radosgw\_keystone **(set to True)**
* radosgw\_keystone\_admin\_user
* radosgw\_keystone\_admin\_password
* radosgw\_keystone\_admin\_tenant

### Run the deployment

```bash
ceph-ansible -i <link to your inventory file> playbooks/deploy-ceph.yml -e @<link to your vars file>
```

### Endpoint setup

Endpoint setup is manual for this installation type, please see upstream documantation for endpoint setup.

## Installation of rgw with an external keystone auth system and automated endpoint setup
Please refer to other documentation for the RPC guidelines for installing and setting up OpenStack Keystone.
This ceph rgw guide assumes you have a working OpenStack Keystone deployment as it is necessary for endpoint setup.

### Install rgw addtions to the inventory file.

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
**Special Note**: You will need to have access to the keystone admin uri endpoint from the deployment host.

### Preset variables
RPC-ceph has already assigned some ceph-ansible variables in **(playbooks/group_vars/rgws.yml)[https://raw.githubusercontent.com/rcbops/rpc-ceph/master/playbooks/group_vars/rgws.yml]**

If you need to override ceph.conf variables use the `ceph_conf_overrides_extra` variable hash within your vars file.

### Make sure you have each of these variables set in your vars file
* public\_network
* internal\_lb\_vip\_address
* service\_region
* radosgw\_keystone **(set to True)**
* radosgw\_keystone\_endpoint\_setup **(set to True)**
* radosgw\_keystone\_admin\_user
* radosgw\_keystone\_admin\_password
* radosgw\_keystone\_admin\_tenant
These need to match the password/admin\_user/tenant defined in your keystone/openstack deployment.
* keystone\_admin\_user\_name
* keystone\_auth\_admin\_password
* keystone\_admin\_tenant\_name
* keystone\_service\_adminuri\_insecure

### Run the deployment
```bash
ceph-ansible -i <link to your inventory file> playbooks/deploy-ceph.yml -e @<link to your vars file>
```


## Load Balancers and SSL Certs
A load balancer should be deployed prior to ceph rgw install and you have VIP.  Currently RPC terminates SSL in the load balancer so the Ceph Object Store does not need anything for SSL set.

F5:  ?

HAProxy:
This is a bit tricky since we don't have IP/containers to point to. I'd advise against creating the swift group and then just not deploying it, because we (a) don't want the containers for swift at all, and (b) don't want them in the inventory. The haproxy group would have to be slightly different anyway (healthcheck wise etc).
In the last deploy we created a dummy group for ceph in /etc/openstack_deploy/env.d/ and then added some "cephrgw" hosts to a group, for the purposes of haproxy - this is probably the best way to go about it for haproxy right now, I've put a patch upstream to allow us to manually specify ip address info for haproxy endpoints (https://review.openstack.org/#/c/527847/) but I'm trying to get that backported.
Lastly, create the appropriate vars for Ceph:
Something like this: https://review.openstack.org/#/c/517856/8/group_vars/ceph-rgw.yml



