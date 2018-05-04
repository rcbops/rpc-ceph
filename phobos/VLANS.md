# Phobos Lab VLANs

When deploying a cluster in the phobos lab you will need to configure ceph_interfaces with the vlans you want
to use for the public and cluster networks.  There is currently no mechanism to test whether a vlan is already
in use.  You should coordinate with the other users of the phobos lab to identify available networks.

```
Vlan 267 4788235-ENV52723-PHO-DEV1 172.20.52.0/24 -> dev1-private
Vlan 268 4788235-ENV52723-PHO-DEV2 172.20.53.0/24 -> dev2-private
Vlan 269 4788235-ENV52723-PHO-DEV3 172.20.54.0/24 -> dev3-private
Vlan 270 4788235-ENV52723-PHO-DEV4 172.20.55.0/24 -> dev4-private
Vlan 271 4788235-ENV52723-PHO-DEV5 172.20.56.0/24 -> dev5-private
Vlan 279 4788235-ENV52723-PHO-DEV6 172.20.57.0/24 -> dev6-private
Vlan 280 4788235-ENV52723-PHO-DEV7 172.20.58.0/24 -> dev7-private
Vlan 286 4788235-ENV52723-PHO-DEV8 172.20.59.0/24 -> dev8-private
```

