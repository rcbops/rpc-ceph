# rpc-ceph and ceph-ansible

``rpc-ceph`` deploys Ceph as an RPC stand-alone platform in a uniform,
managed, and tested way to ensure version consistency and testing.

By adding automated tests, ``rpc-ceph`` provides a way to manage tested
versions of ``ceph-ansible`` used in RPC deployments.

## Current versions of ceph-ansible & Ansible

### **ceph-ansible version:** v3.0.34

### **Ansible version:** 2.4.4.0

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
 * ``rsyslog_all`` host, pointing to an existing or new rsyslog logging server.
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

3. Set any override vars in playbooks/group_vars/host_group/overrides.yml, this allows:

   * Defaults to remain, but be overriden if required (overrides.yml will take precedence).
   * Git will ignore the overrides.yml file, so the repo can be updated without clearing out all deploy specific vars.

4. Override any variables from ``ceph.conf`` using ``ceph_conf_overrides_extra`` or ``ceph_conf_overrides_<group>_extra``:

   * This allows the default ``group_vars`` to remain in place, and means you do not have to respecify any vars you aren't setting.
   * The ``ceph_conf_overrides_<group>_extra`` var will override only vars for only the hosts in that group, with currently supported groups:
     * ceph_conf_overrides_rgw_extra
     * ceph_conf_overrides_mon_extra
     * ceph_conf_overrides_mgr_extra
     * ceph_conf_overrides_osd_extra
   * The overrides will merge with the existing settings and take precedence but not squash them.

5. Run the ``bootstrap-ansible.sh`` inside the scripts directory:

   ```bash
   ./scripts/bootstrap-ansible.sh
   ```

6. This configures ansible at a pre-tested version, creates a ``ceph-ansible``
   binary that points to the appropriate ansible-playbook binary, and clones the
   required role repositories:

   * ``ceph-ansible``
   * ``rsyslog_client``
   * ``openstack-ansible-plugins`` (``ceph-ansible`` uses the config template plugin from here).
   * ``haproxy_server``
   * ``rsyslog_server``

7. Run the ``ceph-ansible`` playbook from the playbooks directory:

   ```bash
   ceph-ansible-playbook -i <link to your inventory file> playbooks/deploy-ceph.yml -e @<link to your vars file>
   ```

7. Run any additional playbooks from the playbook directory:

   * ``ceph-setup-logging.yml``will setup rsyslog client, ensure you have the appropriate rsyslog server setup, or other log shipping location, refer to: https://docs.openstack.org/openstack-ansible-rsyslog_client/latest/ for more details
   * ``ceph-keystone-rgw.yml`` will setup required keystone users and endpoints for Ceph.
   * ``ceph-rgw-haproxy.yml`` will setup the HAProxy VIP for Ceph Rados GW. Ensure you specify ``haproxy_all`` group in your inventory with the HAProxy hosts.
   * ``ceph-rsyslog-server.yml`` will setup rsyslog server on the ``rsyslog_all`` hosts specified. **NB** If there is already an existing rsyslog server that you are connecting into, you should not run this.

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

### AIO Scenarios

To run an AIO scenario for Ceph you can run the following export on a general1-8
or perf2-15 flavor instance, unless otherwise noted:
#export RE_JOB_SCENARIO="name of scenario from below"

**functional**:
This is a base AIO for Ceph, includes MaaS testing, this runs on each
commit, with the following components:

* 2 x rgw hosts
* 3 x osd hosts
* 3 x mon hosts
* 3 x mgr hosts
* 1 x rsyslog server
* HAproxy configured on localhost

This job does not run the benchmarking playbooks.

**bluestore**:
This is the same as the functional job but runs using bluestore, and
3 collocated OSD devices per osd host.

**rpco_newton**:
An RPC-O newton-rc integration test, that will deploy an RPC-O AIO, and
integrate it with Ceph, followed by Tempest tests. This runs daily, as it takes
a long time to build.

* RPC-O AIO @ newton-rc
  * Keystone
  * Glance
  * Cinder
  * Nova
  * Neutron
  * Tempest
* 2 x rgw hosts
* 3 x osd hosts
* 3 x mon hosts
* 3 x mgr hosts

NB: This requires a perf2-15 instance.

**rpco_master**
This is the same as the rpco_newton job but built against the master-rc branch
of RPC-O.

**rpco_pike**
This is the same as the rpco_newton job but built against the pike-rc branch
of RPC-O.

**keystone_rgw**:
A basic keystone integration test, that will run on each commit.
Utilizing the swift client to ensure Keystone integration is working.

* Keystone deployed from OpenStack-Ansible role
* 2 x rgw hosts
* 3 x osd hosts
* 3 x mon hosts
* 3 x mgr hosts

Additionally this test runs the FIO and RGW benchmarking playbooks to ensure
they work, but does not run the MaaS playbooks.

### Currently not supported for AIO

* Trusty deployments - due to changes in losetup trusty will not work with
  the current method.
* Different Ceph versions.
* Upgrade testing.
