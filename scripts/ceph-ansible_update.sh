#!/usr/bin/env bash

## Ensure you run from a clean rpc-ceph repo at head of master with no
## changes made.
## To use this script, simply run the script from the scripts directory
## or the repository base directory. This script will clone ceph-ansible into
## /tmp/ceph-ansilbe_rpc_ceph (to avoid overwriting in the random case where
## ceph-ansible was cloned into /tmp).
## The latest tag will be retrieved, and the group_vars/group_name.yml.sample
## and site.yml.sample files will be copied into the appropriate places in
## rpc-ceph.
## All changes will be added, and a commit will be made. Review the commit and
## PR as appropriate!

CURRENT_DIR=$(basename $PWD)
PATH_TO_PLAYBOOKS=""
PATH_TO_SCRIPTS="scripts/"
if [ "$CURRENT_DIR" == "scripts" ]; then
  PATH_TO_PLAYBOOKS="../"
  PATH_TO_SCRIPTS=""
fi	

## Clone ceph-ansible master
git clone https://github.com/ceph/ceph-ansible /tmp/ceph-ansible_rpc-ceph
pushd /tmp/ceph-ansible_rpc-ceph
## Get the latest tag and save that
git fetch --tags
LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
popd
## Cleanup ceph-ansible dir
rm -rf /tmp/ceph-ansible_rpc-ceph

## Download the site.yml.sample and group_vars.yml.sample files
wget https://raw.githubusercontent.com/ceph/ceph-ansible/$LATEST_TAG/site.yml.sample -O ${PWD}/${PATH_TO_PLAYBOOKS}playbooks/deploy-ceph.yml
git add ${PATH_TO_PLAYBOOKS}playbooks/deploy-ceph.yml
for vars_file in mons mgrs rgws osds all; do
  wget https://raw.githubusercontent.com/ceph/ceph-ansible/$LATEST_TAG/group_vars/$vars_file.yml.sample -O ${PWD}/${PATH_TO_PLAYBOOKS}playbooks/group_vars/$vars_file/$vars_file.yml.sample
  git add ${PATH_TO_PLAYBOOKS}playbooks/group_vars/$vars_file/$vars_file.yml.sample
done

## Update the role requirements file
./${PATH_TO_SCRIPTS}ansible-role-requirements-editor.py -f ${PATH_TO_PLAYBOOKS}ansible-role-requirements.yml -n "ceph-ansible" -v "${LATEST_TAG}"
git add ${PATH_TO_PLAYBOOKS}ansible-role-requirements.yml

git commit -m "Bump ceph-ansible to ${LATEST_TAG}"
