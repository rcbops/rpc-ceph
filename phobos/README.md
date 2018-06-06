# Install rpc-ceph in the Phobos lab OnMetal 

This setup is meant to bootstrap infrastructure via ironic in the Phobos Lab and deploy Ceph onto those nodes using rpc-ceph.
[Benchmarking](../benchmark) and rpc-maas are not included here but could be run as post configuration.

## Get Access

You need to Request VPN access and a Phobos Cloud login (domain: rpc-storage-domain, project: rpc-storage-project)
to the phobos lab from either:
* #rpc-ceph slack channel
* [Shannon Mitchell](mailto:shannon.mitchell@rackspace.com)
* [Keith Fralick](mailto:keith.fralick@rackspace.com)

## Connect to the VPN

Use your credentials to connect to the phobos VPN via Cisco anyconnect or the openconnect client

## Change your password

Your initial password will be a temporary password like `changeme`.  Login to the [Horizon WebUI](https://172.20.4.10) and change it

## Setup your clouds.yaml file

* replace `your.username` with your username
* replace `yourpassword` with your password

```bash
mkdir -p ~/.config/openstack
cat <<EOF >> ~/.config/openstack/clouds.yaml
clouds:
  phobos:
    auth:
      auth_url: http://172.20.4.10:5000/v3
      project_name: rpc-storage-project
      username: your.username
      password: yourpassword
      domain_name: rpc-storage-domain
    region_name: RegionOne
    interface: internal
    auth_version: 3
    identity_api_version: 3
EOF
```

## Install python virtualenv(optional but recommended)

### On Ubuntu

```bash
sudo apt-get install -y python-virtualenv virtualenvwrapper
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
```

### On MacOS

```bash
brew install pyenv-virtualenv pyenv-virtualenvwrapper
source /usr/local/bin/virtualenvwrapper.sh
```

## Initialize virtualenv(if you are using virtualenv)

`mkvirtualenv phobos-lab`

## Install the Openstack client

`pip install python-openstackclient`

## Import or Create SSH key for deployment

```bash
usage: openstack keypair create [-h] [-f {json,shell,table,value,yaml}]
                                [-c COLUMN] [--max-width <integer>]
                                [--fit-width] [--print-empty] [--noindent]
                                [--prefix PREFIX]
                                [--public-key <file> | --private-key <file>]
                                <name>

Create new public or private key for server ssh access

positional arguments:
  <name>                New public or private key name

optional arguments:
  -h, --help            show this help message and exit
  --public-key <file>   Filename for public key to add. If not used, creates a
                        private key.
  --private-key <file>  Filename for private key to save. If not used, print
                        private key in console.
```

Example: `openstack --os-cloud phobos keypair create --public-key ~/.ssh/mykey.pub mykey`

## Initialize an SSH-AGENT

Example:
```bash
$ ssh-agent
SSH_AUTH_SOCK=/tmp/ssh-1PTuB3P1bJBZ/agent.11511; export SSH_AUTH_SOCK;
SSH_AGENT_PID=11512; export SSH_AGENT_PID;
echo Agent pid 11512;
$ SSH_AUTH_SOCK=/tmp/ssh-1PTuB3P1bJBZ/agent.11511; export SSH_AUTH_SOCK;
$ SSH_AGENT_PID=11512; export SSH_AGENT_PID;
$ ssh-add my-ssh-key
```

## Configuration

Example config files can be found in the phobos dir. If you want to use dedicated VLANs in your deployment look [here](VLANS.md)

## Deployment

The `cluster_deploy_version` must be unique to each deployment.  If you reuse `cluster_deploy_version` you will simply
manage the existing installation instead of deploying new.  To check what versions are currently deployed use:

`openstack --os-cloud phobos server list`

Hostnames are in the form ceph-<cluster_deploy_version>-stor-#

From the root of the rpc-ceph repo clone:
* set `ssh_keyname` to the name of your phobos lab ssh key
* set `cluster_deploy_version` to the version you wish to deploy or manage
* set `stor_count` to the number of storage nodes to deploy
* set `client_count` to the number of clients desired.
* Optionally set `rpc_ceph_version` to a specific version of rpc-ceph or a pull request ref you would like to test

```bash
$ pip install -r requirements.txt ansible==2.4.4.0
$ ansible-playbook -e cluster_deploy_version=example-v01 \
                   -e ssh_keyname=mykey \
                   -e stor_count=3 \
                   -e client_count=1 \
                   -e @phobos/vm-vars.yml \
                   playbooks/phobos-deploy.yml
$ ssh ubuntu@admin-node-ip
$ cd /opt/rpc-ceph
$ ceph-ansible-playbook -i inventory -e @phobos/vm-vars.yml playbooks/deploy.yml
```

