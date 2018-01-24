# Setting up Ceph Object Gateway for different RPC Use Cases

Ceph Object Gateway(rgw) is an object storage interface built on top of librados to provide applications with a RESTful gateway to Ceph Storage Clusters. Ceph Object Storage supports two interfaces  S3 and OpenStack Swift.   

Complete documentation for the Ceph Object Gateway can be found (here.)[http://docs.ceph.com/docs/master/radosgw/]

## Role of rpc-ceph
The purpose of (rpc-ceph)[https://github.com/rcbops/rpc-ceph] is to provide a consistant versioned set of processes, variables and versioned software for RPC's use.  

### List of Use Cases

* General Installation using ceph-ansible
* Configuring rgw to use a Stand alone instance of OpenStack Keystone
* Configuring rgw to use KeyStone and Interact with an OpenStack environment in place of OpenStack Swift



## Installation of rgw only
To Install rgw **ONLY** and **NOT** use any of rpc-ceph configured varibles 

### To install rgw addtions to the inventory file.   

Add the **rgw** group with a list of hosts into the ceph environment's inventory file. 
For example:
```bash
[rgw]
ceph-rgw01
ceph-rgw02
ceph-rgw03
```

### Installation variables
Set aside the rpc-ceph preconfigured variables
```bash
cp playbooks/group_vars/rgws.yml playbooks/group_vars/rgw-rpc-ceph.yml.sample
cp playbooks/group_vars/rgws.yml.sample playbooks/group_vars/rgws.yml
```
**Special Note**  Using this approach will install rgw with the ceph-ansible defaults and you will be responsible for assigning all configuration variables needed for your environment that differ from the ceph-ansible defaults

### Run the deployment
```bash
ceph-ansible -i <link to your inventory file> playbooks/deploy-ceph.yml -e@<link to your vars file>
```



## Installation of rgw with Stand Alone Openstack KeyStone
To Install rgw and connect it to a Stand Alone instance of OpenStack Keystone.   Please refer to other documentation for the RPC guidelines for installing and setting up OpenStack Keystone.   This ceph rgw guide assumes you have an working OpenStack Keystone system in place

### To install rgw addtions to the inventory file.   

Add the **rgw** group with a list of hosts into the ceph environment's inventory file. 
For example:
```bash
[rgw]
ceph-rgw01
ceph-rgw02
ceph-rgw03

[keystone_all]
keystone_host
```

### Preset variables
rpc-ceph has already assigned some ceph-ansible variable in the file **(playbooks/group_vars/rgws.yml)[https://raw.githubusercontent.com/rcbops/rpc-ceph/master/playbooks/group_vars/rgws.yml]**  If special needs are required for a specific customer's requirements these variable can be changed or overridden

Make changes these lines from the file **playbooks/group_vars/rgws.yml** because they are used for integration with OpenStack
```
# Replace these 
radosgw_keystone_service_name: "swift"
radosgw_keystone_service_description: "Swift Service"
# with this
# Replace these 
radosgw_keystone_service_name: "ceph"
radosgw_keystone_service_description: "Ceph Object Service"
```

### Make sure you have each of these variables set in your vars file
* public_network
* internal_lb_vip_address
* service_region
* radosgw_keystone **(set to True)**
* keystone_service_adminurl
* radosgw_keystone_admin_user
* radosgw_keystone_admin_password
* radosgw_keystone_admin_tenant
* What from this?   https://github.com/rcbops/rpc-ceph/blob/master/playbooks/ceph-keystone-rgw.yml

### Run the deployment
```bash
ceph-ansible -i <link to your inventory file> playbooks/deploy-ceph.yml -e@<link to your vars file>
```


## Installation of rgw with Openstack KeyStone and OpenStack Ansible
To Install rgw and connect it to a Stand Alone instance of OpenStack Keystone.   Please refer to other documentation for the RPC guidelines for installing and setting up OpenStack Keystone.   This ceph rgw guide assumes you have an working OpenStack Keystone system in place

### To install rgw addtions to the inventory file.   

Add the **rgw** group with a list of hosts into the ceph environment's inventory file. 
For example:
```bash
[rgw]
ceph-rgw01
ceph-rgw02
ceph-rgw03

[keystone_all]
keystone_host
```

### Preset variables
rpc-ceph has already assigned some ceph-ansible variable in the file **(playbooks/group_vars/rgws.yml)[https://raw.githubusercontent.com/rcbops/rpc-ceph/master/playbooks/group_vars/rgws.yml]**  If special needs are required for a specific customer's requirements these variable can be changed or overridden

### Make sure you have each of these variables set in your vars file
* public_network
* internal_lb_vip_address
* service_region
* radosgw_keystone **(set to True)**
* keystone_service_adminurl
* radosgw_keystone_admin_user
* radosgw_keystone_admin_password
* radosgw_keystone_admin_tenant
* What from this?   https://github.com/rcbops/rpc-ceph/blob/master/playbooks/ceph-keystone-rgw.yml

### Run the deployment
```bash
ceph-ansible -i <link to your inventory file> playbooks/deploy-ceph.yml -e@<link to your vars file>
```


## Load Balancers and SSL Certs
A load balancer should be deployed prior to ceph rgw install and you have VIP.  Currently RPC terminates SSL in the load balancer so the Ceph Object Store does not need anything for SSL set



