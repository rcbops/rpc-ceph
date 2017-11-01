## rpc-ceph
This aims to form a platform for deploying Ceph for RPC standalones
in a uniform, managed and tested way.

By providing a way to manage the version of ceph-ansible that is tested
and used in RPC deployments, by adding automated testing.

### Virtual Machine requirements for AIO
 * RAX Public Cloud general-8 (or equivalent)
 * xenial
 * CentOS7

### To run an AIO build
For MaaS integration first perform the following export commands.
Otherwise just use ./run_tests.sh to build the AIO.

```
export PUBCLOUD_USERNAME=<username>
export PUBCLOUD_API_KEY=<api_key>
export IRR_CONTEXT=master
```

### Tested builds
ceph-ansible deployments including RGW.
Testing of Ceph components (RGW testing is currently implemented)
RPC-MaaS integration
RPC-O integration (coming a bit less soon).

### Currently not supported for AIO
Trusty deployments - due to changes in losetup trusty won't work with the
current method.
Different Ceph versions
Upgrade testing
