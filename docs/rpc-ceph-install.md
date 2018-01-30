# Installation Procedures for Ceph in an RPC Customer Environment using rpc-ceph



This process assumes that all servers already have either Ubuntu installed, all network configuration (incl bonding) is complete, and the servers are accessible via ssh.
The servers involved in the deployment must be identified and the role(s) of each server clearly defined.  Every deployment needs "mons", "mgrs" and "osds".  Some deployments may also need RadosGW "rgws".  In a small deployment, a server may have all of these roles assigned.  In larger deployments, each server will typically be assigned fewer, or just a single role.
In most cases, it is preferable to have separate networks for "Storage Front-end" (client access to the storage) and "Storage Back-end" (replication traffic within the cluster), but the "Storage Back-end" network is not required.
The host from which the deployment will be managed must be identified.  This MAY be an "admin" server, "director" server or simply the first of the ceph storage servers, but it is USUALLY the first ceph storage server.  ALL of the following steps are to be performed on this deployment host.

## Base Installation of Ceph using rpc-ceph

### Create entries in /etc/hosts for all servers, specifying the IP address to which we can reach the servers via ssh:
/etc/hosts
Example **/etc/hosts** snippet:
```bash
192.168.0.101 ceph-stor01
192.168.0.102 ceph-stor02
192.168.0.103 ceph-stor03
192.168.0.104 ceph-stor04
192.168.0.105 ceph-stor05
```


### Configure password-less root ssh login from the deployment host to all other hosts. Methods will vary, but typically involve generating a ssh-keypair on the deployment host and using ssh-copyid to distribute the public key to each other node.


### Install "git",  and other dependencies using the distribution repositories:
Install git
```bash
apt-get -y install git software-properties-common python-software-properties
```


### Clone the rpc-ceph repository.  Standard practice is to put this under the /opt directory
To see the versions of `ansible` and `ceph-ansible` supported in this version view the ~~README.md~ file.
```bash
cd /opt
git clone  https://github.com/rcbops/rpc-ceph.git ; cd rpc-ceph
```


### Setup the virtual environment, create wrappers clone necessary repos and install ansible
Run bootstrap-ansible.sh
```bash
./scripts/bootstrap-ansible.sh
```


### Create an ansible inventory file.  
This file should be given a meaningful name for the deployment (ie: rs_clouda_dev_inventory, customera_prod_inventory, etc).  The inventory must contain sections for all "roles" which are to be deployed ("mon", "osds", "rgws", "mdss"). Each server may appear multiple times, if it is to receive multiple roles.  These name must match those listed in the /etc/hosts file.

Example of an ansible inventory file
```bash
[all]
ceph-stor01
ceph-stor02
ceph-stor03
ceph-stor04
ceph-stor05

[all:vars]
ansible_python_interpreter=/usr/bin/python3

[mgrs]
ceph-mon01
ceph-mon02
ceph-mon03

[mons]
ceph-mon01
ceph-mon02
ceph-mon03
 
[osds]
ceph-stor01
ceph-stor02
ceph-stor03
ceph-stor04
ceph-stor05
 
[rgws]
ceph-mon01
ceph-mon02
ceph-mon03
ceph-mon04
ceph-mon05
```

### Verify ansible connectivity to all hosts:
Run an ansible ping
```bash
ceph-ansible -i {inventory file} all -m ping
``` 
Each server should respond "pong". 

Depending how ssh keys were distributed, you may need to confirm adding host keys to known hosts.
If necessary, make any corrections (perhaps errors in /etc/hosts and/or the inventory file),
and re-run the ansible ping command until all servers are reachable without any further interaction. If your OS has default firewall rules, they must be modified to allow ceph traffic.  
 
Other firewall implementations will require other configuration mechanisms, and
of course more specific firewall configuration may be required. Some general guidelines:
* mons listen on port 6789
* osds listen on port numbers starting at 6800 (6801, 6802, 6803, etc.  One port per osd)
* rgws listens on port 8080 by default, but may be configured for any desired port
* mrgs services:
  * dashboard listens on port 7789
  * restful listens on port 8789


### Edit parameter files
You can make changes to the configration parameter by editing the **playbooks/group_vars/[service]/00-default.yml** files. These files will not be overwritten when git pull request is run.  

#### Edit the playbook/group_vars/all/00-defaults.yml file:
The file is well documented with comments and default values.  Several RPC specific settings have already been put in place and any customer specific changes should be placed here.
The most common values which need to be modified are:
```bash 
monitor_interface: eth3           # Must specify the physical interface that monitors use to communicate with the "Storage Front-end" network
public_network: 192.168.0.0/24    # The IP network used on the "Storage Front-end" network
cluster_network: 192.168.200.0/24 # The IP network used on the "Storage Back-end" network
 ```


#### Edit the playbooks/group_vars/mons/00-defaults.yml file:
The file is well documented with comments and default values. RPC and customer specific configurations should be placed here.
```bash 
Assuming this cluster will be used by Openstack, set "openstack_config" to true so that common openstack pools and users are
auto-created for us:
 
openstack_config: true
 
There are other openstack related options here, which you may wish to review, but in most cases, no further changes
are needed.
 
If this ceph cluster will not be used by openstack, then it is likely that no changes to this file are needed.
```

#### Edit the playbook/group_vars/mgrs/00-defaults.yml 
This file is new with the luminous version 
with comments and default values.  RPC and customer specific configurations should be placed here.
```bash
Typically, no changes are required to this file.
```


#### Edit the playbook/group_vars/osds/00-defualt.yml file:
The file is well documented with comments and default values. RPC and customer specific settings should be placed here:
```bash
Several "Storage Scenarios" are describe in this file. 
Uncomment and populate the values which correspond to the current deployment. The most common ones are:
- Journal and osd_data on the same device
- X journal devices for Y OSDs
 
IF all of the ceph-storage nodes have identical disk configuration, then that configuration may be specified here.
 
devices:
  - /dev/sdb
  - /dev/sdc
  - /dev/sdd
  - /dev/sde
raw_journal_devices:
  - /dev/sdf
  - /dev/sdf
  - /dev/sdg
  - /dev/sdg
 
(in the above example, two partitions will be created on /dev/sdf - one as a journal
for /dev/sdb and the other as a journal for sdc.  Similarly, two journal partitions will
be created on /dev/sdg for storage devices /dev/sdd and /dev/sde)
 
(raw_journal_devices only needs to be defined if there are separate journal disks.)
 
(set this to true if cluster has multiple journal nodes)
 
raw_multi_journal: true
IF the disk configurations of the storage servers is not consistent, then it is best to leave
the "devices" and "raw_journal_devices" undefined in this file.  Instead these values should be
specified for each server in the ansible inventory file. Example inventory file entries:
[osds]
ceph-stor01  devices="['/dev/sdb','/dev/sdc','/dev/sdd']" raw_journal_devices="['/dev/sde']"
ceph-stor02  devices="['/dev/sde','/dev/sdf",'/dev/sdg']" raw_journal_devices="['/dev/sdb','/dev/sdc','/dev/sdd']"
```

#### Edit the playbook/group_vars/rgws/00-defaults.yml 
If deploying rgw, review the playbooks/group_vars/rgws/00-default.yml file and make any needed changes:
```bash
Typically, no changes are required to this file.
Note that a number of radosgw_* configuration parameters are defined in the group_vars/all.yml file.
```

### Run the playbook install ceph:
```bash
ceph-ansible-playbook -i <link to your inventory file> playbooks/deploy-ceph.yml
```
 
### There will be quite a lot of activity output.
Verify results:
```bash
(these commands need to be run on a "mons" node.  If deployment was not performed from
one of the mons, then you will need to ssh into a mon, and then run these commands.)
 
# ceph -s
Is the cluster in an "HEALTH_OK" status?
Are the expected number of "mons" in the cluster?
Are the expected number of "osds" (disks) seen? Are they all "up" and "in"?
 
# ceph df
Create any additional needed pools:
ceph osd pool create {pool-name} {pg} {pgp}
 
Now is a good time to increase the number of placement groups (PGs), as needed. 
There is a nice online PG calculator here: http://ceph.com/pgcalc/
```


### Modify CRUSH tunables, if appropriate.  
Typical default ceph tunables are a balance between optimal performance and backwards compatibility.  IF the clients in this environment will use the same version of ceph as the cluster itself, the tunables should be set to "optimal".  This forfeits some backwards compatibility to take full advantage of the current version.  IF the clients in this environment will be using a older version of ceph than the cluster itself (for example, the cluster is running jewel, but the rbd clients are running hammer), then the tunables should be set for client compatibility.
```bash
(these commands need to be run on a "mon" node.  If deployment was not performed from
one of the mons, then you will need to ssh into a mon, and then run these commands.)
 
Show details of the current tunables:
# ceph osd crush show-tunables
 
Examples:
 
Set tunables to "optimal" for current version (suitable if all clients are running this same ceph version):
# ceph osd crush tunables optimal
 
Set tunables to "hammer" for "jewel" cluster with "hammer" clients:
# ceph osd crush tunables hammer
 
Set tunables for maximum backwards compatibility, sacrificing recent features and performance improvements:
# ceph osd crush tunables legacy
```

### Ceph Users Created for Use with Openstack
IF "openstack_config" was set to true, some ceph user accounts and keys were automatically created for use by Openstack.  Retrieve the keys for these users(glance, cinder, cinder-backup):
```bash 
The openstack "nova" and "cinder" services both use the "cinder" ceph user account.
 
(these commands need to be run on a "mon" node.  If deployment was not performed from
one of the mons, then you will need to ssh into a mon, and then run these commands.)
 
# ceph auth get client.[account name]
 
This command will show the user's key and permissions. 
The openstack deployment will just need the ceph user name (without the "client." prefix) and key.
 
Examples:
 
# ceph auth get client.glance
exported keyring for client.glance
[client.glance]
    key = AQCK9/BYImsNBBAAhbAHJ24VqZEufzHo/BZeKg==
    caps mon = "allow r"
    caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=images"
 
# ceph auth get client.cinder
exported keyring for client.cinder
[client.cinder]
    key = AQCK9/BY4k18IRAAUAVLJT9RillGvC7rAqaRqg==
    caps mon = "allow r"
    caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images"
 
# ceph auth get client.cinder-backup
exported keyring for client.cinder-backup
[client.cinder-backup]
    key = AQCL9/BYKHEgAxAA+s0c2WHKCHbli/HxYvigxQ==
    caps mon = "allow r"
    caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=backups"
 
You will also need the ceph cluster UUID and IP addresses of the "mon" nodes. 
This information can be obtained from the "ceph -s" command:
 
Example:
# ceph -s
    cluster b7ffc78f-1a12-44d4-9c10-f031b884a509          <--- CLUSTER UUID
     health HEALTH_OK           IP ADDRS OF MONS---v------------------------------v---------------------------------v
     monmap e1: 3 mons at {scottg-ceph-mon=192.168.36.1:6789/0,scottg-ceph01=192.168.36.5:6789/0,scottg-ceph02=192.168.36.3:6789/0}
            election epoch 8, quorum 0,1,2 scottg-ceph-mon,scottg-ceph02,scottg-ceph01
     osdmap e26: 6 osds: 6 up, 6 in
            flags sortbitwise,require_jewel_osds
      pgmap v57: 80 pgs, 5 pools, 0 bytes data, 0 objects
            202 MB used, 449 GB / 449 GB avail
                  80 active+clean
```


### After Initial deployment set openstack_config to false
If "openstack_config" was set to true, now change it to false.  Once the initial deployment is complete, we don't want these playbooks messing with the openstack pools, users or permissions:
In the group_vars/mons.yml file, change:
```bash
FROM:
openstack_config: true
 
TO:
openstack_config: false
``` 
 

## Ceph Integration with RPC OpenStack(RPCO)

Current documentation of the Integration pieces of Ceph and OpenStack 
https://github.com/rsoprivatecloud/rpc-deployments/blob/master/installs/newton/RPCO_Ceph-Ansible_install.md
 

## Integration of Ceph Object Storage (RGW) with OpenStack
Information on setting up RGW with RPC Openstack can be found here:
https://github.com/rcbops/rpc-ceph/blob/master/docs/rgw_setup.md


## References
https://one.rackspace.com/pages/viewpage.action?title=Ceph+-+Deployment+Using+Ceph-Ansible&spaceKey=PPAGES

