# Install rpc-ceph in the Phobos lab OnMetal 


## Create Environment
* 1 admin vm
* 1 rsyslog vm
* 5 boxes for storage nodes

```bash
openstack server create --flavor  vm-osa-aio --image a4a9bc69-de27-4cec-903a-cf57be693738 \
  --nic net-id=8dd6207d-a1f5-4dfe-b97d-a8c967eb8548  --security-group 58753c65-1804-4eee-8349-77f1c5573001 \
  --key-name letterjkey ceph-admin01-c_

openstack server create --flavor  vm-osa-aio --image a4a9bc69-de27-4cec-903a-cf57be693738 \
  --nic net-id=8dd6207d-a1f5-4dfe-b97d-a8c967eb8548  --security-group 58753c65-1804-4eee-8349-77f1c5573001 \
  --key-name letterjkey rsyslog01-c_

openstack server create --flavor ironic-rpc-storage-interim  --image 78856fa6-1de4-42d3-b545-466f6501e21f \
  --nic net-id=8dd6207d-a1f5-4dfe-b97d-a8c967eb8548  --security-group 58753c65-1804-4eee-8349-77f1c5573001 \
  --key-name letterjkey ceph-stor01-c_

openstack server create --flavor ironic-rpc-storage-interim  --image 78856fa6-1de4-42d3-b545-466f6501e21f \
  --nic net-id=8dd6207d-a1f5-4dfe-b97d-a8c967eb8548  --security-group 58753c65-1804-4eee-8349-77f1c5573001 \
  --key-name letterjkey ceph-stor02-c_

openstack server create --flavor ironic-rpc-storage-interim  --image 78856fa6-1de4-42d3-b545-466f6501e21f \
  --nic net-id=8dd6207d-a1f5-4dfe-b97d-a8c967eb8548  --security-group 58753c65-1804-4eee-8349-77f1c5573001 \
  --key-name letterjkey ceph-stor03-c_

openstack server create --flavor ironic-rpc-storage-interim  --image 78856fa6-1de4-42d3-b545-466f6501e21f \
  --nic net-id=8dd6207d-a1f5-4dfe-b97d-a8c967eb8548  --security-group 58753c65-1804-4eee-8349-77f1c5573001 \
  --key-name letterjkey ceph-stor04-c_

openstack server create --flavor ironic-rpc-storage-interim  --image 78856fa6-1de4-42d3-b545-466f6501e21f \
  --nic net-id=8dd6207d-a1f5-4dfe-b97d-a8c967eb8548  --security-group 58753c65-1804-4eee-8349-77f1c5573001 \
  --key-name letterjkey ceph-stor05-c_
```


## Storage Nodes favor ironic-rpc-storage-interim additional drives
/dev/sdb | 3TB
...
/dev/sdk | 3TB


## Phobos Xenial image is set to not allow root user to log in
To remove the restriction run this on each osd node and on rsyslog
```bash
ssh ubuntu@<ip>  "sudo sed -i -e 's/^no-port-forwardin.*\(ssh-rsa.*$\)/\1/g' /root/.ssh/authorized_keys"
```


##  hosts file
Create entries in /etc/hosts for all servers, specifying the IP address to which we can reach the servers via ssh:
Example **/etc/hosts** snippet:
```bash
/etc/hosts
172.20.41.X    ceph-admin01-c_ 
172.20.41.X    rsyslog01-c_
172.20.41.X    ceph-stor01-c_
172.20.41.X    ceph-stor02-c_
172.20.41.X    ceph-stor03-c_
172.20.41.X    ceph-stor04-c_
172.20.41.X    ceph-stor05-c_
```

## Passwordless root ssh 
Configure password-less root ssh login from the deployment host to all other hosts. Methods will vary, but typically involve generating a ssh-keypair on the deployment host and using ssh-copyid to distribute the public key to each other node.

On the admin vm create an **ssh-key**
```bash
ssh-keygen -t ed25519 -C cephdeploy
```

Push the public key generated to each server in the cluster
```bash
 ssh-copy-id -i ~/.ssh/id_ed25519 root@<server ip>
```


## Clone rpc-ceph repo and set up directories
Clone repo
```bash
cd /opt && git clone https://github.com/rcbops/rpc-ceph.git
```
Set up phobos directory
```bash
cd rpc-ceph && mkdir phobos
```


## Install and Setup up Ansible

```bash
apt-get update
apt install --yes python-pip
./scripts/bootstrap-ansible.sh 
```

# Setup Inventory File
Create file /opt/rpc-ceph/phobos/inventory
```
[ceph-cluster]
rsyslog01-c_
ceph-stor01-c_
ceph-stor02-c_
ceph-stor03-c_
ceph-stor04-c_
ceph-stor05-c_

[ceph-cluster:vars]
ansible_python_interpreter=/usr/bin/python3

[mgrs]
ceph-stor01-c_		ansible_host="172.20.41.X"
ceph-stor02-c_		ansible_host="172.20.41.X"
ceph-stor03-c_		ansible_host="172.20.41.X"
 
[mons]
ceph-stor01-c_		ansible_host="172.20.41.X"
ceph-stor02-c_		ansible_host="172.20.41.X"
ceph-stor03-c_		ansible_host="172.20.41.X"
 
[osds]
ceph-stor01-c_		ansible_host="172.20.41.X"
ceph-stor02-c_		ansible_host="172.20.41.X"
ceph-stor03-c_		ansible_host="172.20.41.X"
ceph-stor04-c_		ansible_host="172.20.41.X"
ceph-stor05-c_		ansible_host="172.20.41.X"
 
[rgws]
ceph-stor01-c_		ansible_host="172.20.41.X"
ceph-stor02-c_		ansible_host="172.20.41.X"
ceph-stor03-c_		ansible_host="172.20.41.X"
ceph-stor04-c_		ansible_host="172.20.41.X"
ceph-stor05-c_		ansible_host="172.20.41.X"
 
[rsyslog_all]
rsyslog01-c_		  ansible_host="172.20.41.X"
```


## Verify Ansible Install, Connectivity and Inventory file
```
ceph-ansible <cluster group> -i phobos/inventory -m ping
```


## Variables File

```bash
---
monitor_interface: bond0
public_network: 172.20.41.0/24
cluster_network: 172.20.41.0/24
osd_scenario: non-collocated
devices:
  - /dev/sdd
  - /dev/sde
  - /dev/sdf
  - /dev/sdg
  - /dev/sdh
  - /dev/sdi
  - /dev/sdj
  - /dev/sdk

dedicated_devices:
  - /dev/sdb
  - /dev/sdb
  - /dev/sdb
  - /dev/sdb
  - /dev/sdc
  - /dev/sdc
  - /dev/sdc
  - /dev/sdc
```

## Deploy Ceph 

```bash
 ceph-ansible-playbook -i phobos-c1/c1-inventory  playbooks/deploy-ceph.yml -e @phobos-c1/c1-vars.yml
```
