#!/usr/bin/env bash
# Copyright 2015, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# In order to install this, you must already have ran run_tests.sh
# with an rpco scenario: RE_JOB_SCENARIO=rpco_(newton|ocata|pike|queens)
# You also need to have created a MaaS entity for your AIO host.

# MaaS needs these set.
#export PUBCLOUD_API_KEY=
#export PUBCLOUD_USERNAME=

export RE_JOB_SCENARIO=ceph
export RPCO_DIR=${RPCO_DIR:-/opt/rpc-openstack}
export RPC_MAAS_DIR=${RPC_MAAS_DIR:-/etc/ansible/ceph_roles/rpc-maas}

export CLONE_DIR="$(pwd)"
export ANSIBLE_INVENTORY="${CLONE_DIR}/tests/inventory_rpco_maas"
export ANSIBLE_PARAMETERS="-e @${CLONE_DIR}/tests/test-vars.yml -e @${CLONE_DIR}/tests/maas-ceph-vars.yml -e @${RPC_MAAS_DIR}/tests/user_rpcm_secrets.yml"
export ANSIBLE_BINARY=ceph-ansible-playbook

cp ${CLONE_DIR}/tests/inventory_rpco ${ANSIBLE_INVENTORY}

if ! grep -q utility_container ${ANSIBLE_INVENTORY}; then
  UTILITY_HOST=$(lxc-ls -f | grep utility_container | awk {'print $1'})
  UTILITY_HOST_IP=$(grep $UTILITY_HOST /etc/hosts | awk {' print $1 '})
  echo -e "\n[utility_all]\n$UTILITY_HOST ansible_host=$UTILITY_HOST_IP" >> ${ANSIBLE_INVENTORY}
fi

if ! grep -q cinder_api_container ${ANSIBLE_INVENTORY}; then
  CINDER_API_HOST=$(lxc-ls -f | grep cinder_api_container | awk {'print $1'})
  CINDER_API_HOST_IP=$(grep $CINDER_API_HOST /etc/hosts | awk {' print $1 '})
  echo -e "\n[cinder_api]\n$CINDER_API_HOST ansible_host=$CINDER_API_HOST_IP" >> ${ANSIBLE_INVENTORY}
fi

if ! grep -q cinder_volumes_container ${ANSIBLE_INVENTORY}; then
  CINDER_VOLUME_HOST=$(lxc-ls -f | grep cinder_volumes_container | awk {'print $1'})
  CINDER_VOLUME_HOST_IP=$(grep $CINDER_VOLUME_HOST /etc/hosts | awk {' print $1 '})
  echo -e "\n[cinder_volume]\n$CINDER_VOLUME_HOST ansible_host=$CINDER_VOLUME_HOST_IP" >> ${ANSIBLE_INVENTORY}
fi

if ! grep -q cinder_scheduler_container ${ANSIBLE_INVENTORY}; then
  CINDER_SCHEDULER_HOST=$(lxc-ls -f | grep cinder_scheduler_container | awk {'print $1'})
  if ! [ -z "$CINDER_SCHEDULER_HOST" ]; then
    CINDER_SCHEDULER_HOST_IP=$(grep $CINDER_SCHEDULER_HOST /etc/hosts | awk {' print $1 '})
    echo -e "\n[cinder_scheduler]\n$CINDER_SCHEDULER_HOST ansible_host=$CINDER_SCHEDULER_HOST_IP" >> ${ANSIBLE_INVENTORY}
  fi
fi

if ! grep -q cinder_all ${ANSIBLE_INVENTORY}; then
  echo -e "\n[cinder_all]\n$CINDER_API_HOST ansible_host=$CINDER_API_HOST_IP" >> ${ANSIBLE_INVENTORY}
  echo -e "$CINDER_VOLUME_HOST ansible_host=$CINDER_VOLUME_HOST_IP" >> ${ANSIBLE_INVENTORY}
  if ! [ -z "$CINDER_SCHEDULER_HOST" ]; then
    echo -e "$CINDER_SCHEDULER_HOST ansible_host=$CINDER_SCHEDULER_HOST_IP" >> ${ANSIBLE_INVENTORY}
  fi
fi

pushd ${RPC_MAAS_DIR}
apt-get install -y apt-transport-https
bash tests/test-ansible-functional.sh
popd

