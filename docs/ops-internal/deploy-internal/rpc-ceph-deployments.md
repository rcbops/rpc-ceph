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