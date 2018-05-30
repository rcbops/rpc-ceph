# Dashboards

## Grafana

To install grafana to visualize prometheus metrics you need to first add a grafana group in your inventory
with the node(s) that you want to host `grafana` on.  Then run the `grafana.yml` playbook to install and
configure grafana.  You will get a few default dashboards for ceph and node_exporter as well as the
promethues data source configured by default to point to your first prometheus node.  The default
username and password are both `admin`.  You can access grafana via the public IP of your grafana node
port 3000.  If you would like to change username/password/other install options take a look at the full
list of variables found here [grafana module](https://github.com/ansiblebit/grafana/blob/2.14.2/defaults/main.yml).

To test if Grafana is working bring up `http://<grafana-ip>:3000` as user 'admin' and pass 'admin' unless
you have overriden the defaults for any of those values.  Grafana should come up preloaded with dashboards
and with prometheus configured as a datasource, assuming you have already deployed prometheus see: [monitoring](monitoring.md).
