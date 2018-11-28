# Integrating rpc-ceph with elk_metrics_6x

You can collect metrics from Ceph nodes using [elk_metrics_6x](https://github.com/openstack/openstack-ansible-ops/tree/master/elk_metrics_6x) via metricbeat.
Metricbeat will be used to collect host metrics from the Ceph nodes and the prometheus plugin for metricbeat
will be used to collect Ceph metrics from the Prometheus plugin for the Ceph Mgr service.

**NOTE: the elk_metrics_6x plays require ansible >= 2.5.  If you are deploying with an OSA version that uses an**
**older version of ansible you will need to use the embeded ansible in the openstack-ansible-ops repo to deploy**


## Install Metricbeats on Ceph Nodes

### Add Ceph Nodes to OSA Inventory

If you do not already have a inventory group setup to manage your Ceph cluster you will need to create one.

```
# cat <<EOF > /etc/openstack_deploy/env.d/ceph.yml
---
component_skel:
  ceph-ext:
    belongs_to:
      - ceph_ext_all

container_skel:
  ceph-ext_container:
    belongs_to:
      - ceph-ext_containers
    contains:
      - ceph-ext
    properties:
      is_metal: true

physical_skel:
  ceph-ext_containers:
    belongs_to:
      - all_containers
  ceph-ext_hosts:
    belongs_to:
      - hosts
EOF
```

```
# cat <<EOF > /etc/openstack_deploy/conf.d/ceph.yml
ceph-ext_hosts:
  ceph-perf-stor-1:
    ip: 172.20.58.41
  ceph-perf-stor-2:
    ip: 172.20.58.42
  ceph-perf-stor-3:
    ip: 172.20.58.43
  ceph-perf-stor-4:
    ip: 172.20.58.44
  ceph-perf-stor-5:
    ip: 172.20.58.45
  ceph-perf-stor-6:
    ip: 172.20.58.46
EOF
```

### Configure Metricbeat Prometheus Module

Configure the container or node that will be using metricbeats to collect metrics from Ceph via the
Prometheus plugin for the Ceph Mgr service by providing the list of Ceph Mgr node IPs for the **br-mgmt**
network.  In the example below we are using the elastic-logstash containers to collect metrics from
Ceph.  The below config goes in `/etc/openstack_deploy/conf.d/elk.yml`.

```
elastic-logstash_hosts:
  logging01:
    ip: 172.20.52.16
    container_vars:
      prometheus_enabled: true
      prometheus_config:
        - hosts:
            - "172.20.52.41:9283"
            - "172.20.52.42:9283"
            - "172.20.52.43:9283"
          namespace: ceph
```


### Install Metricbeats

When you install metricbeat limit it the ceph nodes you want to deploy to.  In the above config we used
`ceph_ext_all` as the ceph node group.  If your inventory differs be sure to update the group name.
Similiarly if you choose to collect metrics from Ceph using a different group than `elastic-logstash_hosts`
replace that here as well.

```
# cd /opt/openstack-ansible-ops/elk_metrics_6x/
# openstack-ansible installMetricbeat.yml --limit elastic-logstash_hosts,ceph_ext_all --skip-tags setup
```


## Add Grafana Dashboard

## Configure Grafana

Clone the Grafana role and copy the grafana config. Be sure to edit `/etc/openstack_deploy/conf.d/grafana.yml`
and set the IP address of the host you are deploying grafana to.

```
# git clone https://github.com/cloudalchemy/ansible-grafana /etc/ansible/roles/grafana
# cp /opt/openstack-ansible-ops/grafana/conf.d/grafana.yml /etc/openstack_deploy/conf.d
# cp /opt/openstack-ansible-ops/grafana/env.d/grafana.yml /etc/openstack_deploy/env.d
```

Configure Grafana variables by appending the grafana endpoint config to `haproxy_extra_services` 

```
haproxy_extra_services:
  - service:
      haproxy_service_name: grafana
      haproxy_ssl: False
      haproxy_backend_nodes: "{{ groups['grafana'] | default([]) }}"
      haproxy_port: 3000  # This is set using the "grafana_port" variable
      haproxy_balance_type: tcp
```

Add the Grafana Datasource config to `/etc/openstack_deploy/user_variables.yml`

```
grafana_datasources:
  - name: elasticsearch
    type: elasticsearch
    access: proxy
    url: 'http://{{ internal_lb_vip_address }}:9201'
    basicAuth: false
    jsonData:
      esVersion: 6
      keepCookies: []
      maxConcurrentShardRequests: 256
      timeField: "@timestamp"
```

### Deploy Grafana

Create the Grafana container and update haproxy

```
# cd /opt/openstack-ansible/playbooks
# openstack-ansible lxc-containers-create.yml -e 'container_group=grafana'
# openstack-ansible haproxy-install.yml
```

Install Grafana

```
# cd /opt/openstack-ansible-ops/grafana/
# openstack-ansible installGrafana.yml
```

### Add Ceph Overview Dashboard

Download the Ceph Overview Dashboard found [here](https://github.com/rcbops/rpc-ceph/tree/master/elk_6x_integration/Ceph_Cluster_Overview.json).   Login to Grafana
and import the dashboard setting the datasource to `elasticsearch`.  Next navigate to the dashboard settings
and select variables.  There are 4 variables for this dashboard that need updated:

* ceph_disk - regex should match the OSD devices to be monitored per node
* ceph_hosts - regex should match the Ceph nodes to be monitored
* public_interface - The interface of the Ceph public_network
* cluster_interface - The interface of the Ceph cluster_network.  If you do not have a seperate replication network reuse the public_interface here

Set the variables above based on the Ceph cluster to be monitored
