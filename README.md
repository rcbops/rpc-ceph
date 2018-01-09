# rpc-ceph
This aims to form a platform for deploying Ceph for RPC standalones
in a uniform, managed and tested way. Ensuring version consistency and testing.

By providing a way to manage the version of ceph-ansible that is tested
and used in RPC deployments, by adding automated testing.

## What is rpc-ceph?
rpc-ceph is a very thin wrapper around the ceph-ansible project. In it's
simplest form it is a way to manage the version of ansible and ceph-ansible
providing:
 * RPC integration testing (MaaS/Logging & WIP-OpenStack)
 * Tested and versioned ceph-ansible and Ceph releases.
 * Default variables (still WIP) that can be used for base installs.
 * A standardized way of deploying that isn't just "clone ceph-ansible"
 * Default playbooks for integration.
 * Benchmarking tools using fio.

This means, it is essentially an ansible bootstrap.sh, and vanilla ceph-ansible,
with a few default group_vars specified, and a pre-created playbook ready to go.
Anything that can be configured/done with ceph-ansible can also be done with rpc-ceph.

## Deploying Ceph for multi-node/Production environments
### Architecture
Within rpc-ceph we do not recommend/use containers for production deployments.
Containers are setup and used as part of the run_tests.sh (AIO) testing strategy
only, so that we can test a full build out with minimal hardware, but are not the
recommended architecture for production. As such the default playbooks are not set
up to build containers or configure any of the required container specific roles.

The inventory should consist of the following:
 * 1-3+ mons hosts (perferably 3 or more), and an uneven number of them.
 * 1-3+ mgrs hosts (perferably 3 or more) - Ideally on the mon hosts. (Since Luminous this is required)
 * 3+ osds hosts, with storage drives.
 * 1-3+ rgws hosts (optional) - these will be loadbalanced.
 * rsyslog_all host, pointing to the existing rsyslog logging server.
 * benchmark_hosts (optional) - the host on which to run benchmarking (Read benchmark/README.md for more)

### Configuring your deployment host
To begin a deployment, you need to configure your inventory, including:
  * "ansible_host" var
  * devices, dedicated_devices for osd hosts
Configure a variables file including the following ceph-ansible vars:
  * monitor_interface
  * public_network
  * cluster_network
  * osd_scenario
  * any other ceph-ansible settings you want to configure.
  
Now you run the bootstrap-ansible.sh inside the scripts directory:
```
# ./scripts/bootstrap-ansible.sh
```

This configures ansible at a pre-tested version and clones the required role repositories:
 * ceph-ansible
 * rsyslog_client
 * openstack-ansible-plugins (ceph-ansible uses the config template plugin from here).

###
Now run the ceph-ansible playbook from the playbooks directory:

```
# ansible-playbook -i <link to your inventory file> playbooks/deploy-ceph.yml -e @<link to your vars file>
```

That should be it!
If anything goes wrong, treat it as a normal ceph-ansible deployment, since that is exactly what it is.

## Deploying Ceph as an AIO
### Virtual Machine requirements for AIO
 * RAX Public Cloud general-8 (or equivalent) using:
   * Ubuntu 16.04 (xenial)
   * CentOS7

### To run an AIO build
For MaaS integration first perform the following export commands.
Otherwise just use ./run_tests.sh to build the AIO.

```
export PUBCLOUD_USERNAME=<username>
export PUBCLOUD_API_KEY=<api_key>
export IRR_CONTEXT=master
```

### Tested builds as AIO
ceph-ansible deployments including RGW.
Testing of Ceph components (RGW testing is currently implemented)
RPC-MaaS integration
RPC-O integration (coming a bit less soon).

### Currently not supported for AIO
Trusty deployments - due to changes in losetup trusty won't work with the
current method.
Different Ceph versions
Upgrade testing
