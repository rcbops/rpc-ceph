## rpc-ceph
This aims to form a platform for deploying Ceph for RPC standalones
in a uniform, managed and tested way.

By providing a way to manage the version of ceph-ansible that is tested
and used in RPC deployments, by adding automated testing.

### Virtual Machine requirements for AIO
Rackspace Public Cloud
 * general-8
 * xenial

### To run an AIO build
```
export PUBCLOUD_USERNAME=<username>
export PUBCLOUD_API_KEY=<api_key>
(exports are only required when setting up MaaS checks for Ceph)
./run_tests.sh
```

### Tested builds
ceph-ansible deployments including RGW.
Testing of Ceph components (coming soon)
RPC-MaaS integration (coming soon)
RPC-O integration (coming a bit less soon).

### Currently not supported for AIO
Trusty deployments - due to changes in losetup trusty won't work with the
current method.
Different Ceph versions
