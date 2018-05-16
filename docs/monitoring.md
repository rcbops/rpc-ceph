# Metrics

## Promtheus

Before you begin you need to enable the prometheus module for ceph mgr.  Ensure that you add 'prometheus' to the
array of modules to enable `ceph_mgr_modules` and run the `add-mgr-modules.yml` playbook to enable the module.

If you would like to install prometheus and use it to monitor metrics produced by the ceph mgr prometheus module
you simply need to include a `[prometheus]` group in your inventory that defines the server or servers that you
want to deploy prometheus on.  Then run:
```
 ceph-ansible-playbook -i <inventory> playbooks/prometheus.yml
```

Alternatively if you are using the `deploy.yml` playbook the prometheus play will automatically be included and
applied only if you have a prometheus group deinfed in your inventory.  You can override the prometheus
version that will be installed with the variable `prometheus_version`.  For a full list of variables see here
[prometheus module](https://github.com/idealista/prometheus_server-role/blob/1.3.1/defaults/main.yml).

To test prometheus run:  `curl http://<prometheus-ip>:9090/metrics`

Sample output:
```
...
prometheus_tsdb_tombstone_cleanup_seconds_bucket{le="5"} 0
prometheus_tsdb_tombstone_cleanup_seconds_bucket{le="10"} 0
prometheus_tsdb_tombstone_cleanup_seconds_bucket{le="+Inf"} 0
prometheus_tsdb_tombstone_cleanup_seconds_sum 0
prometheus_tsdb_tombstone_cleanup_seconds_count 0
# HELP prometheus_tsdb_wal_corruptions_total Total number of WAL corruptions.
# TYPE prometheus_tsdb_wal_corruptions_total counter
prometheus_tsdb_wal_corruptions_total 0
# HELP prometheus_tsdb_wal_fsync_duration_seconds Duration of WAL fsync.
# TYPE prometheus_tsdb_wal_fsync_duration_seconds summary
prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.5"} 0.000389566
prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.9"} 0.00042114
prometheus_tsdb_wal_fsync_duration_seconds{quantile="0.99"} 0.00056656
prometheus_tsdb_wal_fsync_duration_seconds_sum 18.47457519899999
prometheus_tsdb_wal_fsync_duration_seconds_count 26469
# HELP prometheus_tsdb_wal_truncate_duration_seconds Duration of WAL truncation.
# TYPE prometheus_tsdb_wal_truncate_duration_seconds summary
prometheus_tsdb_wal_truncate_duration_seconds{quantile="0.5"} NaN
prometheus_tsdb_wal_truncate_duration_seconds{quantile="0.9"} NaN
prometheus_tsdb_wal_truncate_duration_seconds{quantile="0.99"} NaN
prometheus_tsdb_wal_truncate_duration_seconds_sum 1.9388906469999998
prometheus_tsdb_wal_truncate_duration_seconds_count 36
```

## Node Exporter

If you would like to enable node exporter to monitor generic server metrics like disk, cpu, memory, network you
can do so by using the `node_exporter.yml` play in the playbooks directory.  This playbook is configured to
deploy node exporter to the mons, mgrs, osds, and rgws groups.  If you have a `prometheus` group in your
inventory the node_exporter playbook will also add the scrape configuration for all your node exporter
endpoints to your prometheus servers so prometheus will gather the node exporter metrics.  If you are
using the `deploy.yml` playbook the node_exporter configuration will be disabled by default.  to enable
set `install_node_exporter: true`.

To test that node_exporter is running run: `curl http://<node-exporter-ip>:9100/metrics`

Sample output:
```
...
node_xfs_extent_allocation_extents_freed_total{device="sdh1"} 2.917294e+06
node_xfs_extent_allocation_extents_freed_total{device="sdi1"} 4.167175e+06
node_xfs_extent_allocation_extents_freed_total{device="sdj1"} 3.851591e+06
node_xfs_extent_allocation_extents_freed_total{device="sdk1"} 4.218183e+06
# HELP process_cpu_seconds_total Total user and system CPU time spent in seconds.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 1114.95
# HELP process_max_fds Maximum number of open file descriptors.
# TYPE process_max_fds gauge
process_max_fds 1024
# HELP process_open_fds Number of open file descriptors.
# TYPE process_open_fds gauge
process_open_fds 11
# HELP process_resident_memory_bytes Resident memory size in bytes.
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 1.7412096e+07
# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1.52691455659e+09
# HELP process_virtual_memory_bytes Virtual memory size in bytes.
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 2.859507712e+09
```

