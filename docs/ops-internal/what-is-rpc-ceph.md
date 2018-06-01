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
