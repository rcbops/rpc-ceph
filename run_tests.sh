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

set -xeuo pipefail

echo "Gate job started"
echo "+-------------------- START ENV VARS --------------------+"
env
echo "+-------------------- START ENV VARS --------------------+"

export FUNCTIONAL_TEST=${FUNCTIONAL_TEST:-true}
export RPC_MAAS_DIR=${RPC_MAAS_DIR:-/etc/ansible/roles/rpc-maas}
export IRR_CONTEXT=${IRR_CONTEXT:-"undefined"}

# Install python2 for Ubuntu 16.04 and CentOS 7
if which apt-get; then
    sudo apt-get update && sudo apt-get install -y python
fi

if which yum; then
    sudo yum install -y python
fi

# Install pip.
if ! which pip; then
  curl --silent --show-error --retry 5 \
    https://bootstrap.pypa.io/get-pip.py | sudo python2.7
fi

# CentOS 7 requires two additional packages:
#   redhat-lsb-core - for bindep profile support
#   epel-release    - required to install python-ndg_httpsclient/python2-pyasn1
if which yum; then
    sudo yum -y install redhat-lsb-core epel-release
fi

if [ "${FUNCTIONAL_TEST}" = true ]; then
  export CLONE_DIR="$(pwd)"
  export ANSIBLE_INVENTORY="${CLONE_DIR}/tests/inventory"
  export ANSIBLE_OVERRIDES="${CLONE_DIR}/tests/test-vars.yml"
  export ANSIBLE_BINARY="${ANSIBLE_BINARY:-ceph-ansible}"
  bash scripts/bootstrap-ansible.sh
  # Clone the test repos
  "${ANSIBLE_BINARY}" playbooks/git-clone-repos.yml \
       -i ${CLONE_DIR}/tests/inventory \
       -e role_file=../ansible-role-test-requirements.yml
  "${ANSIBLE_BINARY}" -i tests/inventory tests/setup-ceph-aio.yml \
      -e @tests/test-vars.yml
  # Use the rpc-maas deploy to test MaaS
  if [ "${IRR_CONTEXT}" != "ceph" ]; then
    pushd ${RPC_MAAS_DIR}
      bash tests/test-ansible-functional.sh
    popd
  fi
fi
