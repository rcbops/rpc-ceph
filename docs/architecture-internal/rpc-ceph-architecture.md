### Architecture

We do not recommend or use containers for ``rpc-ceph`` production deployments.
Containers are setup and used as part of the ``run_tests.sh`` (AIO) testing
strategy only. The default playbooks are not set up to build containers or
configure any of the required container specific roles.

The inventory should consist of the following:

 * 1-3+ mons hosts (perferably 3 or more), and an uneven number of them.
 * 1-3+ mgrs hosts (perferably 3 or more) - Ideally on the mon hosts
   (Since the Luminous release this is required).
 * 3+ osds hosts with storage drives.
 * OPTIONAL: 1-3+ rgws hosts - these will be load balanced.
 * ``rsyslog_all`` host, pointing to an existing or new rsyslog logging server.
 * OPTIONAL:``benchmark_hosts`` - the host on which to run benchmarking
   (Read ``benchmark/README.md`` for more).