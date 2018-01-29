# rpc-ceph and ceph-ansible

``rpc-ceph`` deploys Ceph as an RPC stand-alone platform in a uniform,
managed, and tested way to ensure version consistency and testing.

By adding automated tests, ``rpc-ceph`` provides a way to manage tested
versions of ``ceph-ansible`` used in RPC deployments.

## What is rpc-ceph?

``rpc-ceph`` is a thin wrapper around the ``ceph-ansible`` project.
``rpc-ceph`` manages the versions of ansible and ``ceph-ansible``
by providing:

 * RPC integration testing (MaaS/Logging and WIP-OpenStack).
 * Tested and versioned ``ceph-ansible`` and Ceph releases.
 * Default variables (still WIP) for base installs.
 * Standarized deployments.
 * Default playbooks for integration.
 * Benchmarking tools using ``fio``.

Deploying ``rpc-ceph`` uses ``boostrap.sh``, ``ceph-ansible``, default
``group_vars``, and a pre-created playbook.

**NOTE:** Anything that can be configured with ``ceph-ansible`` is configurable with
``rpc-ceph``.

## Deploying Ceph for multi-node and production environments

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
 * ``rsyslog_all`` host, pointing to the existing rsyslog logging server.
 * OPTIONAL:``benchmark_hosts`` - the host on which to run benchmarking
   (Read ``benchmark/README.md`` for more).

### Configuring your deployment host

1. Configure the following inventory:

   * ``ansible_host`` var for each host.
   * Devices, ``dedicated_devices`` for osd hosts.

2. Configure a variables file including the following ``ceph-ansible`` vars:

   * ``monitor_interface``
   * ``public_network``
   * ``cluster_network``
   * ``osd_scenario``
   * Any other ``ceph-ansible`` settings you want to configure.

3. Override any variables from ``ceph.conf`` using ``ceph_conf_overrides_extra``:

   * This allows the default ``group_vars`` to remain in place, and means you do not have to respecify any vars you aren't setting.

4. Run the ``bootstrap-ansible.sh`` inside the scripts directory:

   ```bash
   ./scripts/bootstrap-ansible.sh
   ```

5. This configures ansible at a pre-tested version, creates a ``ceph-ansible``
   binary that points to the appropriate ansible-playbook binary, and clones the
   required role repositories:

   * ``ceph-ansible``
   * ``rsyslog_client``
   * ``openstack-ansible-plugins`` (``ceph-ansible`` uses the config template plugin from here).

6. Run the ``ceph-ansible`` playbook from the playbooks directory:

   ```bash
   ceph-ansible -i <link to your inventory file> playbooks/deploy-ceph.yml -e @<link to your vars file>
   ```

Your deployment should be successful.

**NOTE:** If there are any errors, troubleshoot as a standard ``ceph-ansible`` deployment.

## Deploying Ceph as an AIO

### Virtual Machine requirements for AIO

 * RAX Public Cloud general-8 (or equivalent) using:
   * Ubuntu 16.04 (xenial)
   * CentOS7

### To run an AIO build

For MaaS integration, perform the following export commands.
Otherwise just use ``./run_tests.sh`` to build the AIO.

```bash
export PUBCLOUD_USERNAME=<username>
export PUBCLOUD_API_KEY=<api_key>
```

### Tested builds as AIO

* ceph-ansible deployments including RGW.
* Testing of Ceph components (RGW testing is currently implemented)
* RPC-MaaS integration
* RPC-O integration (coming a bit less soon).

### Currently not supported for AIO

* Trusty deployments - due to changes in losetup trusty will not work with
  the current method.
* Different Ceph versions.
* Upgrade testing.
