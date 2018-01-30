# RPC-Ceph Scripts

## bootstrap-ansible.sh

This script is designed to setup Ansible and other requirements for RPC-Ceph:

* Clone required roles defined in ``ansible-role-requirements.yml`` into the
  /etc/ansible/roles directory.
* Install the version of Ansible defined by ``ANSIBLE_PACKAGE`` in the
  bootstrap-ansible.sh script, into a virtual environment.
* Setup SSH Keys.
* Configure a ``ceph-ansible`` and ``ceph-ansible-playbook`` scripts that
  reference the ``ansible`` and ``ansible-playbook`` binary for rpc-ceph, within
  the virtual environment. This allows rpc-ceph to have it's own tested and
  working version of Ansible without conflicting with any other Ansible installs


## ceph-ansible_increment_release.sh

This script is designed to update the version of ceph-ansible in use in the
rpc-ceph repo itself. The aim is to keep rpc-ceph playbooks and sample
group_vars 100% in line with ceph-ansible itself.

* Cloning ceph-ansible and retrieving the latest tagged version number.
* Update the deploy-ceph.yml playbook by copying directly for the
  site.yml.sample sample playbook carried by ceph-ansible.
* Update the sample group_vars by copying the group_vars directly from
  ceph-ansible itself.
* Update the README.md to reference the new version of ceph-ansible.

The script will remind the user this is not to be run in production, you can
circumvent this by passing the flat --i-really-really-mean-it.

**NB** This is not for use on production systems, it will just bump the version
of ceph-ansible in ansible-role-requirements, as well as the deploy-ceph.yml
playbook and sample group_vars. If you accidentally run this in production
simply revert the commit, or do a "git --reset" to the previous commit's SHA.
**NB** We still need to verify that any changes to the sample group_vars do not
impact our existing defaults.
This script requires the pyYAML pip package to run, but can be run on a Mac.
