# Ceph Metrics Installation Guide

Take the following steps to active the metrics inside Ceph for Node_Exporter, install Prometheus and Grafana and setup the collection and presentation.


## Setup Prometheus and Grafana metrics for Red Hat Ceph


* Cluster mush be running luminous
* For this test we will assume that Prometheus and Grafana will run on the "rsyslog" server
* Change the Grafana user and password if you choose to


### Modify Configuration Files

* Insert this at the end of of your vars.yml file 

```
ceph_mgr_modules:
  - restful
  - status
  - balancer
  - prometheus

install_node_exporter: true

# Set grafana admin user and password
#grafana:
#  admin_user: admin
#  admin_password: admin
```
    
* Add a '[promethues]' group and include the destination server for example: rsyslog 
* Add the '[grafana]' group and include the destination server for example: rsyslog 


### Run the following playbooks

```
ceph-ansible-playbook -i <inventory> playbooks/add-mgr-modules.yml -e@<location>/vars.yml
ceph-ansible-playbook -i <inventory> playbooks/prometheus.yml -e@<location>/vars.yml
ceph-ansible-playbook -i <inventory> playbooks/node_exporter.yml -e@<location>/vars.yml
ceph-ansible-playbook -i <inventory> playbooks/grafana.yml -e@<location>/vars.yml
```

### Verify Installation Success

* Node Exporter:
```
curl http://<node>:9100/metrics
```

* Prometheus:
```
curl http://<prometheus-ip>:9090/metrics
```

* Grafana
```
http://<grafana-ip>:3000 as user admin with password admin
```
