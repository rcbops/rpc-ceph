
## Standalone Ceph installation
(aka the Newton method) 


### Gather information           


On each Ceph node, take note of how many drives there are, and which drives are 
SSDs and HDDs. This will be important later. 


` ssacli ctrl slot=<0-3> pd all show `

    The ones you care about are those under "unassigned". There should be 
    2 600GB RAID 1 drives. These hold the OS. DO NOT TOUCH THESE. 

Example output:

```

ssacli ctrl slot=3 pd all show

Smart Array P840 in Slot 3

   array A

      physicaldrive 1I:1:1 (port 1I:box 1:bay 1, Solid State SATA, 960.1 GB, OK)   <-- This is where the OS lives
      physicaldrive 1I:1:2 (port 1I:box 1:bay 2, Solid State SATA, 960.1 GB, OK)   <-- This is where the OS lives

   unassigned

      physicaldrive 1I:1:3 (port 1I:box 1:bay 3, Solid State SATA, 960.1 GB, OK)  <-- This is what we care about
      physicaldrive 1I:1:4 (port 1I:box 1:bay 4, Solid State SATA, 960.1 GB, OK)  <-- This is what we care about
      physicaldrive 1I:1:5 (port 1I:box 1:bay 5, Solid State SATA, 960.1 GB, OK)  <-- This is what we care about
      physicaldrive 1I:1:6 (port 1I:box 1:bay 6, Solid State SATA, 960.1 GB, OK)  <-- This is what we care about
      physicaldrive 1I:1:7 (port 1I:box 1:bay 7, Solid State SATA, 960.1 GB, OK)  <-- This is what we care about
      physicaldrive 1I:1:8 (port 1I:box 1:bay 8, Solid State SATA, 960.1 GB, OK)  <-- This is what we care about
      physicaldrive 2I:2:1 (port 2I:box 2:bay 1, Solid State SATA, 960.1 GB, OK)  <-- This is what we care about
      physicaldrive 2I:2:2 (port 2I:box 2:bay 2, Solid State SATA, 960.1 GB, OK)  <-- This is what we care about
      physicaldrive 2I:2:3 (port 2I:box 2:bay 3, Solid State SATA, 960.1 GB, OK)  <-- This is what we care about
      physicaldrive 2I:2:4 (port 2I:box 2:bay 4, Solid State SATA, 960.1 GB, OK)  <-- This is what we care about

```

NOTE: The drives may be in one large RAID group (array B), which if they are, you will need to break up that RAID group before moving on



### Set up RAID 0             


If the drives are in a single large RAID group (not together with the OS), you 
will need to break up the group before building the RAID 0 groups. 

` ssacli ctrl slot=<0-3> ld 2 delete `

Go back to the Gather information step and ensure that the output appears 
similar to what is shown.



For each drive listed under "Unassigned" execute the following

` ssacli ctrl slot=<0-3> create type=ld drives=<drive_label> raid=0 `

This will create a RAID 0 group with a single drive in it. The drive will
be assigned a /dev/sd* label and should appear if you run ` lsblk `

If you are presented with a prompt about SSD OverProvisioning (OP), answer N and 
move on to the next drive. SSD OP is not a feature we use since we allocate all
of the physical space to a logical volume.


### Download rpc-ceph and configure your deployment host

Install needed packages on the deployment host:
` apt-get install -y git-core `

Clone rpc-ceph:
` cd /opt; git clone https://github.com/rcbops/rpc-ceph `

Run the bootstrap-ansible.sh script:
` bash scripts/bootstrap-ansible.sh `

This will configure ansible inside a virtualenvironment, and download the required
roles for Ceph.


### Set /etc/hosts            

On the deployment node, add each Ceph node to the deployment host's /etc/hosts file. 

It should look something like: 
```
192.168.0.11  ceph-mon1
192.168.0.12  ceph-mon2
192.168.0.13  ceph-mon3
192.168.0.101 ceph-stor01
192.168.0.102 ceph-stor02
192.168.0.103 ceph-stor03
192.168.0.104 ceph-stor04
```

Also, if not done already, create an ssh key and add the public key to 
/root/.ssh/authorized_keys on each ceph node. The goal is to create 
passwordless login from the ceph deployment node.

You can use copy-paste or ssh-copy-id (if you know the password for root)


### Set Inventory and Configs      


This is where the information you pulled from above is important. 

Check your build ticket. If you do not see something about dedicated mons nodes, 
do not worry about it. 

However, if one of your Ceph nodes is not like the others (They should look 
the same), check with your DE to make sure there aren't any special 
considerations that need to be made. 

Typically, we will use the first 3 Ceph nodes (ceph01, ceph02, ceph03) as mons
nodes. The ceph-mons service CAN BE RUN on the same node as the ceph-osd service.
This means that a ceph node can be both a mons node and an osds node. 


```
[mons]
123456-mon01
234567-mon02
345678-mon03

# If using Luminous uncomment the following lines
#[mgrs]
#123456-mon01
#234567-mon02
#345678-mon03

[osds]
123456-osd01
234567-osd02
345678-osd03

# Only if using RadosGW
[rgws]
123456-radosgw01
234567-radosgw02
```

Name your inventory ceph_inventory!

Create any config files for non-default settings:
Defaults are stored in playbooks/group_vars/<group>/00-defaults.yml
You can see the commented ceph-ansible file for the version for ceph-ansible in use at playbooks/group_vars/<group>/<group>.yml.sample
Do not edit these files, they will be updated as you move between versions.

To adjust settings per group create a file inside the directory for example:
playbooks/group_vars/<group>/overrides.yml

You will need to add cluster specific settings inside playbooks/group_vars/all/overrides.yml:
```bash
monitor_interface: br-storage
public_network: {storage-network-CIDR}
cluster_network: {replication-network-CIDR}
```

If you using Jewel instead of Luminous you should add the following to playbooks/group_vars/all/overrides.yml
```bash
ceph_stable_release: jewel  # If you are deploying Luminous, change this to Luminous
```

If there are jumbo frames add the following to playbooks/group_vars/all/overrides.yml:
```bash
ceph_conf_overrides_extra:
  osd:
    osd_heartbeat_min_size: 9000
```

If there are any additional config_overrides required you can add them as above.
This allows the defaults to be adhered to, but overridden by specified settings, without
removing all existing defaults.

When integrating with OpenStack ensure the following settings are set inside playbooks/group_vars/mons/overrides.yml:
```bash
openstack_config: True
```

And inside playbooks/group_vars/rgws/overrides.yml, when integrating Keystone with RadosGW:
```bash
radosgw_keystone: true
```

Finally, configure the storage scenario you wish to utilise.
If all devices are the same on all hosts you can specify devices as well.
Add the following to Inside playbooks/group_vars/osds/overrides.yml add,
depending on your scenario:

1. For collocated scenario (journals exist on the same disks as osds):
```bash
osd_scenario: collocated

devices:
  - /dev/sdb
  - /dev/sdc
  - /dev/sdd
  ...

```

2. Dedicated Journals

The Journals (dedicated_devices) must be listed once for each device it is a journal for. See the example in playbooks/group_vars/osds/osds.yml.sample for a better explaination. 

```
osd_scenario: non-collocated

devices:
  - /dev/sdc
  - /dev/sdd
  - /dev/sde
  ...

dedicated_devices:
  - /dev/sdb
  - /dev/sdb
  - /dev/sdb
  ...

```


### Run Playbook              


Check connectivity to the other nodes

` ceph-ansible -i <inventory> all -m ping `

This should return all green 'pongs'. If not, check /etc/hosts and your networking

Run the playbook 

` ceph-ansible-playbook -i <inventory> playbooks/deploy-ceph.yml `

Should this playbook go wrong in any way, shape, or form, OR if any changes must be made 
AFTER ceph has been installed (like changing scenarios), you will need to purge the cluster. This applies only before the cluster is onlined. Once the cluster is onlined, never pugre the cluster.

To purge the cluster run


# !!!!!!! DO NOT RUN THIS IN A PRODUCTION ENVIRONMENT! THIS WIPES ALL OF THE DRIVES! !!!!!!!!

` ceph-ansible-playbook -i <inventory> playbooks/purge-cluster.yml `



### Check Cluster Health         

Check the cluster health with 

` ceph -s `

and ensure that all of your pools were created with 

` ceph df `

If you see a HEALTH_WARN status and something along the lines of "too few pgs" run: 


` ceph osd pool set <pool> pg_num 64 `
` ceph osd pool set <pool> pgp_num 64 `

Do this for each pool and then recheck the status. If it still is not HEALTH_OK, rerun the command 
with the next highest power of 2 (ex 128, 256, 512, 1024, 2048, ...) until the status is HEALTH_OK. 

Finally, run: 

` ceph osd crush tunables optimal `

and ensure the cluster is still healthy with 

` ceph -s `

ensure osds are set to maximum CPU performance

```
Apply the changes
ceph-ansible -i <inventory> osds -m shell -a 'echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
ceph-ansible -i <inventory> osds -m shell -a "for state in 2 3 4; do echo 1 | tee /sys/devices/system/cpu/*/cpuidle/state$state/disable; done
ceph-ansible -i <inventory> osds -m shell -a 'systemctl stop ondemand.service'

Save changes
ceph-ansible -i <inventory> osds -m lineinfile -a 'dest=/etc/rc.local insertbefore="exit 0" line="sleep 5; echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"'
ceph-ansible -i <inventory> osds -m lineinfile -a 'dest=/etc/rc.local insertbefore="exit 0" line="for state in 2 3 4; do echo 1 | tee /sys/devices/system/cpu/*/cpuidle/state$state/disable; done"'
ceph-ansible -i <inventory> osds -m shell -a 'systemctl disable ondemand.service'
```

Put the output from this into the build ticket so it is shown that the cluster was healthy 

You are done with the Ceph installation
