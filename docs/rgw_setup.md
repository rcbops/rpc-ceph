# Setting up Ceph Object Gateway for different RPC Use Cases

Ceph Object Gateway(rgw) is an object storage interface built on top of librados to provide applications with a RESTful gateway to Ceph Storage Clusters. Ceph Object Storage supports two interfaces S3 and OpenStack Swift.

Complete documentation for the Ceph Object Gateway can be found (here.)[http://docs.ceph.com/docs/master/radosgw/]

## Role of rpc-ceph
The purpose of (rpc-ceph)[https://github.com/rcbops/rpc-ceph] is to provide a consistant versioned set of processes, variables and software for RPC's use.

### List of Use Cases

* General Installation using ceph-ansible **without** a preconfigured external Auth System
* General Installation using ceph-ansible **with** a preconfigured external Auth System


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
RPC-ceph has already assigned some ceph-ansible variables in the file **(playbooks/group_vars/rgws/00-defaults.yml)[https://raw.githubusercontent.com/rcbops/rpc-ceph/master/playbooks/group_vars/rgws/00-defaults.yml]**

If you need to override ceph.conf variables use the `ceph_conf_overrides_extra` variable hash within your vars file.

### These variables are required to be populated for **both** use cases.

* public_network
* internal_lb_vip_address or keystone_service_adminurl
* service_region or radosgw_keystone_service_region
* radosgw_keystone ***(set to True)**
* radosgw_keystone_admin_user
* radosgw_keystone_admin_password
* radosgw_keystone_admin_tenant

**NB** If your Auth system is preconfigured: user, tenant & password settings need to match the Auth system's settings.

### Run the deployment
```bash
ceph-ansible-playbook -i <link to your inventory file> playbooks/deploy-ceph.yml -e@<link to your vars file>
```

### These variables are required to be populated when Auth is **not** preconfigured.

* keystone\_admin\_user\_name
* keystone\_auth\_admin\_password
* keystone\_admin\_tenant\_name
* keystone\_service\_adminuri\_insecure

**NB** These must match the Auth system's settings.

### Run the Ceph deployment
```bash
ceph-ansible -i <link to your inventory file> playbooks/deploy-ceph.yml -e@<link to your vars file>
```

### Setup Auth endpoints and users, if **not** preconfigured.
```bash
ceph-ansible-playbook -i <link to your inventory file> playbooks/ceph-keystone-rgw.yml -e@<link to your vars file>
```

## Load Balancers and SSL Certs
A load balancer should be deployed prior to ceph rgw install and you have VIP.  Currently RPC terminates SSL in the load balancer so the Ceph Object Store does not need anything for SSL set.

F5: Liaise with Network Security to configure the F5.

HAProxy:
You can deploy to a new or existing haproxy server by adding it to the ``[haproxy_all]`` group in your inventory and then running the ceph-rgw-haproxy.yml playbook:
```bash
[haproxy_all]
myhaproxyhost
```
```bash
ceph-ansible-playbook -i <link to your inventory file> playbooks/ceph-rgw-haproxy.yml -e@<link to your vars file>
```
