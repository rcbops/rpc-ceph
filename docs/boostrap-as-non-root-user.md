# Bootstrapping RPC-CEPH as non-root user for non-AIO deploys

```
sudo git clone https://github.com/rcbops/rpc-ceph.git -b <branch> /opt/rpc-ceph
cd /opt/rpc-ceph
sudo -s ./scripts/bootstrap-ansible.sh
sudo chown -R ${USER}:$(id -gn) ${HOME}/.ansible
```

