#!/usr/bin/env bash

## For use when updating the ceph-ansible version inside rpc-ceph repo.
## NB This will NOT upgrade a deployed environment, and should not be used in
## production.

while [ "$1" != "--i-really-really-mean-it" ]; do
  read -p "This will update the rpc-ceph repo to use the newest version of ceph-ansible.
!!Do not run this in production!!.
Do you wish to continue? [Y/N] " yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) echo "exiting"; exit;;
  esac
done

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
LATEST_TAG=$(git describe --tags `git rev-list --tags` | grep "v3.0" -m 1)
popd
## Cleanup ceph-ansible dir
rm -rf /tmp/ceph-ansible_rpc-ceph

## Download the site.yml.sample and group_vars.yml.sample files
wget https://raw.githubusercontent.com/ceph/ceph-ansible/$LATEST_TAG/site.yml.sample -O ${PWD}/${PATH_TO_PLAYBOOKS}playbooks/deploy-ceph.yml
wget https://raw.githubusercontent.com/ceph/ceph-ansible/$LATEST_TAG/infrastructure-playbooks/rolling_update.yml -O ${PWD}/${PATH_TO_PLAYBOOKS}playbooks/rolling_update.yml
wget https://raw.githubusercontent.com/ceph/ceph-ansible/$LATEST_TAG/infrastructure-playbooks/osd-configure.yml -O ${PWD}/${PATH_TO_PLAYBOOKS}playbooks/osd-configure.yml
wget https://raw.githubusercontent.com/ceph/ceph-ansible/$LATEST_TAG/infrastructure-playbooks/purge-cluster.yml -O ${PWD}/${PATH_TO_PLAYBOOKS}playbooks/purge-cluster.yml
git add ${PATH_TO_PLAYBOOKS}playbooks/*.yml
for vars_file in mons mgrs rgws osds all; do
  wget https://raw.githubusercontent.com/ceph/ceph-ansible/$LATEST_TAG/group_vars/$vars_file.yml.sample -O ${PWD}/${PATH_TO_PLAYBOOKS}playbooks/group_vars/$vars_file/$vars_file.yml.sample
  git add ${PATH_TO_PLAYBOOKS}playbooks/group_vars/$vars_file/$vars_file.yml.sample
done

## Update the role requirements file
./${PATH_TO_SCRIPTS}ansible-role-requirements-editor.py -f ${PATH_TO_PLAYBOOKS}ansible-role-requirements.yml -n "ceph-ansible" -v "${LATEST_TAG}"
git add ${PATH_TO_PLAYBOOKS}ansible-role-requirements.yml

## Update the supported ceph-ansible version in the README.md
current_version=$(grep "ceph-ansible version:" ${PATH_TO_PLAYBOOKS}README.md | cut -d " " -f4)
## On a Mac we need to work around the terrible Mac sed
if $(uname | grep -iq darwin); then
  sed -i " " "s/$current_version/$LATEST_TAG/" ${PATH_TO_PLAYBOOKS}README.md
else
  sed -i "s/$current_version/$LATEST_TAG/" ${PATH_TO_PLAYBOOKS}README.md
fi
git add README.md

git commit -m "Bump ceph-ansible to ${LATEST_TAG}"
