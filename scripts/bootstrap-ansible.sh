set -e -u -x

export ANSIBLE_PACKAGE=${ANSIBLE_PACKAGE:-"ansible==2.5.7.0"}
export SSH_DIR=${SSH_DIR:-"/root/.ssh"}
export ANSIBLE_ROLE_FILE=${ANSIBLE_ROLE_FILE:-"ansible-role-requirements.yml"}
# Set the role fetch mode to any option [git-clone]
export ANSIBLE_ROLE_FETCH_MODE=${ANSIBLE_ROLE_FETCH_MODE:-git-clone}
ANSIBLE_BINARY="${ANSIBLE_BINARY:-ceph-ansible-playbook}"

# Prefer dnf over yum for CentOS.
which dnf &>/dev/null && RHT_PKG_MGR='dnf' || RHT_PKG_MGR='yum'

# This script should be executed from the root directory of the cloned repo
cd "$(dirname "${0}")/.."

source scripts/scripts-libs.sh
# Store the clone repo root location
export CLONE_DIR="$(pwd)"

# Set the variable to the role file to be the absolute path
ANSIBLE_ROLE_FILE="$(readlink -f "${ANSIBLE_ROLE_FILE}")"
OSA_INVENTORY_PATH="$(readlink -f playbooks/inventory)"
OSA_PLAYBOOK_PATH="$(readlink -f playbooks)"
# Create the ssh dir if needed
ssh_key_create

# Determine distro
determine_distro

# Install the base packages
case ${DISTRO_ID} in
    centos|rhel)
        sudo $RHT_PKG_MGR -y install \
          git curl autoconf gcc gcc-c++ nc \
          python2 python2-devel \
          openssl-devel libffi-devel \
          libselinux-python
        ;;
    ubuntu)
        sudo apt-get update
        DEBIAN_FRONTEND=noninteractive sudo apt-get -y install \
          git python-all python-dev curl python2.7-dev build-essential \
          libssl-dev libffi-dev netcat python-requests python-openssl python-pyasn1 \
          python-netaddr python-prettytable python-crypto python-yaml \
          python-virtualenv
        ;;
esac

PYTHON_EXEC_PATH="${PYTHON_EXEC_PATH:-$(which python2 || which python)}"
PYTHON_VERSION="$($PYTHON_EXEC_PATH -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"

VIRTUALENV_VERSION=$(virtualenv --version 2>/dev/null | cut -d. -f1)
if [[ "${VIRTUALENV_VERSION}" -lt "13" ]]; then

  # Install pip on the host if it is not already installed,
  # but also make sure that it is at least version 7.x or above
  # so that it supports the use of the constraint option which
  # was added in pip 7.1.
  PIP_VERSION=$(pip --version 2>/dev/null | awk '{print $2}' | cut -d. -f1)
  if [[ "${PIP_VERSION}" -lt "7" ]]; then
    get_pip ${PYTHON_EXEC_PATH}
    # Ensure that our shell knows about the new pip
    hash -r pip
  fi

  pip install} \
    virtualenv==15.1.0 \
    || pip install \
         --isolated \
         virtualenv==15.1.0
  # Ensure that our shell knows about the new pip
  hash -r virtualenv
fi

# Create a Virtualenv for the Ansible runtime
if [ -f "/opt/rpc-ceph_ansible-runtime/bin/python" ]; then
  VENV_PYTHON_VERSION="$(/opt/rpc-ceph_ansible-runtime/bin/python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
  if [ "$PYTHON_VERSION" != "$VENV_PYTHON_VERSION" ]; then
    rm -rf /opt/rpc-ceph_ansible-runtime
  fi
fi
virtualenv --python=${PYTHON_EXEC_PATH} \
           --clear \
           --no-pip --no-setuptools --no-wheel \
           /opt/rpc-ceph_ansible-runtime

# Install pip, setuptools and wheel into the venv
get_pip /opt/rpc-ceph_ansible-runtime/bin/python

# The vars used to prepare the Ansible runtime venv
if [ -f "/opt/rpc-ceph_ansible-runtime/bin/pip" ]; then
  PIP_COMMAND="/opt/rpc-ceph_ansible-runtime/bin/pip"
else
  PIP_COMMAND="$(which pip)"
fi
PIP_OPTS+=" --constraint global-requirement-pins.txt"

# Install ansible and the other required packages
${PIP_COMMAND} install ${PIP_OPTS} -r requirements.txt ${ANSIBLE_PACKAGE}

# Create ceph-ansible binary ensuring we use the correct version of ansible
cat <<EOF | sudo tee /usr/local/bin/ceph-ansible
#!/usr/bin/env bash
# Copyright 2018, Rackspace US, Inc.
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

# Wrapper to ensure ceph-ansible is deployed using the Ansible version
# and dependencies required by ceph-ansible.

/opt/rpc-ceph_ansible-runtime/bin/ansible "\${@}"
EOF

sudo chmod +x /usr/local/bin/ceph-ansible
echo "ceph-ansible wrapper created."

# Create ceph-ansible-playbook binary ensuring we use the correct version of ansible
cat <<EOF | sudo tee /usr/local/bin/ceph-ansible-playbook
#!/usr/bin/env bash
# Copyright 2018, Rackspace US, Inc.
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

# Wrapper to ensure ceph-ansible is deployed using the Ansible version
# and dependencies required by ceph-ansible.

/opt/rpc-ceph_ansible-runtime/bin/ansible-playbook "\${@}"
EOF

sudo chmod +x /usr/local/bin/ceph-ansible-playbook
echo "ceph-ansible-playbook wrapper created."

# Update dependent roles
if [ -f "${ANSIBLE_ROLE_FILE}" ]; then
  if [[ "${ANSIBLE_ROLE_FETCH_MODE}" == 'git-clone' ]];then
    ${ANSIBLE_BINARY} playbooks/git-clone-repos.yml \
        -i ${CLONE_DIR}/tests/inventory -e role_file=${ANSIBLE_ROLE_FILE}
  else
    echo "Please set the ANSIBLE_ROLE_FETCH_MODE to either of the following options ['git-clone']"
    exit 99
  fi
fi
