# Ceph Node Addition


**Always check the runbook first**

**Since adding nodes to the cluster triggers a rebalance, this procedure should be performed inside of a maintenance window**

## Adding New OSD Nodes to an Existing Ceph Cluster (Jewel)

Open three sessions to the ceph deployment host

* Let one be your workspace
* Run ` watch ceph -s ` in another
* Run ` watch ceph osd df ` in the last

**Use the sessions running the `watch` commands to monitor the cluster health as you work.**


## THE PROCEDURE

### Add the new node hostnames to /etc/hosts.  
Do this on the *ceph deployment node*:
```bash
~# vim /etc/hosts
~# ceph tell mon.* injectargs --mon_osd_auto_mark_new_in=false
~# ceph tell osd.* injectargs '--osd_max_backfills 1 --osd_recovery_max_active 1'
~# ceph osd set noout
~# ceph osd ls > current_osd_ids
```

### Check the file just to ensure that the copy gave the correct ids.  
Do this on the *ceph deployment node*:
```bash
~# cat current_osd_ids 
~# cd ./rpc-ceph
~/rpc-ceph# cp ceph_inventory ceph_inventory.bak
~/rpc-ceph# vim ceph_inventory
```

### Match whatever is already in the ceph_inventory file. If you have questions, reach out to the Ceph SMEs. Don't make assumptions

**These are just examples. Yours may/will be different**

**ADD THE FOLLOWING TO ADD THE SSD NODES**
```bash
[SSD NODE HOSTNAME]  osd_scenario=collocated devices='["/dev/sdb","/dev/sdc", "/dev/sdd","/dev/sde","/dev/sdf","/dev/sdg","/dev/sdh","/dev/sdi","/dev/sdj","/dev/sdk","/dev/sdl","/dev/sdm","/dev/sdn","/dev/sdo","/dev/sdp","/dev/sdq","/dev/sdr","/dev/sds","/dev/sdt","/dev/sdu","/dev/sdv","/dev/sdw","/dev/sdx","/dev/sdy"]'
```

 **ADD THE FOLLOWING TO ADD HDD NODES**
```bash
[HHD NODE HOSTNAME] osd_scenario=non-collocated dedicated_devices='["/dev/sdb","/dev/sdb","/dev/sdb","/dev/sdb","/dev/sdc","/dev/sdc","/dev/sdc","/dev/sdc"]' devices='["/dev/sdd","/dev/sde","/dev/sdf","/dev/sdg","/dev/sdh","/dev/sdi","/dev/sdj","/dev/sdk"]'
```

### Check connectivity
Do this on the *ceph deployment node*:
```bash
~/rpc-ceph# ceph-ansible -i ceph_inventory all -m ping
```
**ensure that all nodes respond with "pong"**

**AS YOU RUN THE PLAYBOOK, KEEP A CLOSE EYE ON THE CLUSTER HEALTH. THIS WILL CAUSE A REBALANCE. THERE IS NO STOPPING IT. ASK THE ADM IF YOU CAN REBALANCE.**

Do this on the *ceph deployment node*:
```bash
~/rpc-ceph ceph-ansible-playbook -i ceph_inventory playbooks/deploy-ceph.yml
```

### Grab the highest number osd
Do this on the *ceph deployment node*:
```bash
~/rpc-ceph# ceph osd ls 
```

### CREATE A FILE WITH ALL OF THE NEW OSD IDS 
Name the file *new_osds*

**AS YOU INCREASE THE WEIGHTS, MONITOR CLUSTER HEALTH. ASK THE ADM IF YOU CAN REBALANCE**
Do this on the *ceph deployment node*:
```bash
~/rpc-ceph# for item in $(cat new_osds); do echo $item && ceph osd reweight $item .1; done;
~/rpc-ceph# for item in $(cat new_osds); do echo $item && ceph osd reweight $item .2; done;
~/rpc-ceph# for item in $(cat new_osds); do echo $item && ceph osd reweight $item .3; done;
~/rpc-ceph# for item in $(cat new_osds); do echo $item && ceph osd reweight $item .4; done;
~/rpc-ceph# for item in $(cat new_osds); do echo $item && ceph osd reweight $item .5; done;
~/rpc-ceph# for item in $(cat new_osds); do echo $item && ceph osd reweight $item .6; done;
~/rpc-ceph# for item in $(cat new_osds); do echo $item && ceph osd reweight $item .7; done;
~/rpc-ceph# for item in $(cat new_osds); do echo $item && ceph osd reweight $item .8; done;
~/rpc-ceph# for item in $(cat new_osds); do echo $item && ceph osd reweight $item .9; done;
~/rpc-ceph# for item in $(cat new_osds); do echo $item && ceph osd reweight $item 1.0; done;

~/rpc-ceph# ceph tell mon.* injectargs --mon_osd_auto_mark_new_in=true
~# ceph osd unset noout
```

### Check that no extra pools were created
Do this on the *ceph deployment node*:
```bash
~/rpc-ceph# ceph df
```

## Adding in Monitoring
The new nodes should be added into the MaaS Monitoring system. All of these commands should be run on the *ceph deployment node*.

### Go into the rpc-maas directory
```bash
~# cd /opt/rpc-maas
```

### Add the new nodes to the maas inventory and test connectivity
```bash
:/opt/rpc-maas# ansible -i maas_inventory -m ping
``` 
**ensure everything responds with "pong"**

### Run maas playbook
```bash
/opt/rpc-maas# ansible-playbook -i maas_inventory site.yml
```

### Check on monitoring.rackspace.net that all monitors are registering and show as green

## Close out of all sessions, you are finished