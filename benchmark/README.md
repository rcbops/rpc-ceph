## rpc-ceph FIO benchmarking

A set of playbooks to setup and configure an rbd device for
benchmarking, based on the Amazon EBS Benchmark Procedures:
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/benchmark_procedures.html

Run the fio_benchmark.yml to setup, run and cleanup the benchmark pool,
ceph user, and mount point. Add the "benchmark_hosts" inventory group to specify
the host on which to run the benchmarks.

### Specifying a pool
If you would like to use an existing Ceph pool specify this using the
"fiobench_pool_name" variable. If you specify this the scripts will not create
or cleanup pools and will just use that pool to create an image. Otherwise
the scripts will create a pool name "fiobench". You can specify the pgnum and
pgpnum for this pool by specifying the fiobench_pgnum and fiobench_pgpnum
variables, which default to 100.

### Specifying image size
You can specify the size of the image using "fiobench_size" variable which
defaults to 2G. This will be created in the specified pool, or the default
"fiobench" pool.

### List of benchmarks
The ``fio_bench_list_default`` var, defined in ``benchmark_hosts`` group_vars,
is the list of default benchmarks. There are 5 main test scenarios:

ebs_direct_bench - Sequential read, write and rw mix tests using 1M blocks against an nbd-rbd blockdev
ebs_file_bench   - Random read and write tests using 16k blocks against a mounted nbd-rbd blockdev
osa_file_bench   - Random read and write tests using 4k blocks against a mounted nbd-rbd blockdev
ebs_rbd_bench    - Direct random read and write tests using 16k blocks and ioengine=rbd (DEFAULT)
osa_rbd_bench    - Direct random read and write tests using 4k blocks and ioengine=rbd

By default only the ebs_rbd_bench will run.  To run another test simply set it to true.

Example:

`osa_rbd_bench: true`

Additional tests, with different blocksizes, numjobs and iodepth can be added
using the ``fio_bench_list_extras`` var, and specifying a different vars for the
specific test, for example, if you want to add a test to do direct reads
from an rbd device with 32k blocksize, iodepth 8 and numjobs 4:

```
fio_bench_list_extras:
  - src: "fio_direct_test.cfg.j2"
    name: "my_custom_direct_read_test"
    override: "{{ fio_direct_read_test_32k_overrides | default({}) }}"
    blocksize: "32k"
    rw: read
    numjobs: 4
    iodepth: 8
    run_bench: True
```

This will generate a FIO config file in
``/opt/ceph_bench/my_custom_direct_read_test.cfg`` that will be used to run FIO
as part of the ``fio_benchmark_run.yml`` playbook. The logs that are created
will be in ``/opt/ceph_bench/logs/my_custom_direct_read_test.date_time.log``.

Additionally, settings can be overridden using config_template overrides. The
specific overrides var for each benchmark in ``fio_bench_list`` is specified by
the ``override`` var for each item.

### Benchmark log output
The output of all FIO runs are stored in ``/opt/ceph_bench/logs``, with the name
of the job used to generate the log, along with a ``date_time`` value to ensure
that logs are not overwritten on consecutive runs and can instead be compared.

The logs will also be pulled from the benchmark_hosts and written to 
``benchmark/<client_hostname>/<test>.<timestamp>.log``

### Cleaning up a deploy
The cleanup script will unmount, unmap and remove the rbd image, as well as
delete the fiobench pool if "fiobench_pool_name" is not specified.

## rpc-ceph Rados Gateway benchmarking
A set of playbooks to setup and configure a Rados Object Gateway benchmark run.
Run the rgw_benchmark.yml to setup, run and cleanup the software and configurations,
ceph users, and capture the results. Add the "benchmark_hosts" inventory group to specify
the host on which to run the benchmarks.  The benchmark is also set to delete any objects
and containers placed into the system.

### Setup the ceph user and subuser
This benchmark requires a ceph user be created with `radosgw-admin` and a corresponding subuser.
Both of these users will be removed after the benchmark completes as to not leave any potential 
security issues.    The user creatd is *testuser* and the subuser will be *testuser:swift*.

### Setting up the software and general config
The software used for this benchmark is the *bench* command of the *hummingbird* go binary and 
the configuration file is made from the template  **benchmark/templates/rgw_benchmark_test.conf**

### Benchmark configuration options
The parameters you can adjust are concurrency, size of put object, number of objects added 
and number of get requests.  The tool deletes all put objects as a final step.

* bench_rgw_user_password:  password used by the benchmark
* bench_rgw_hummingbird_url: url to the benchmarking tool **hummingbird**
* bench_rgw_concurrency:  number of concurrent operations
* bench_rgw_object_size:   size of the object in bytes used in the benchmark 
* bench_rgw_number_of_objects:  number of objects placed in the system 
* bench_rgw_number_of_gets: number of get requests performed

When choosing the concurrency setting keep in mind the network throughput available on the client boxes. 
When choosing the object size and number settings keep in mind that multiple replicas of the object will 
written into the system so check the clusters available space.   

### Benchmark Settings for an AIO
Due the the fact that rpc-ceph tests are run on an AIO the setting placed in **tests/test-vars.yml** are:
* bench_rgw_concurrency:  15
* bench_rgw_object_size: 256
* bench_rgw_number_of_objects: 5000 
* bench_rgw_number_of_gets: 10000

### Benchmark Settings Defaults
For the benchmark to be useful on production systems the amount of data written and read needs to be significant.
So the benchmarks defaults setting are:
* bench_rgw_concurrency:  50
* bench_rgw_object_size: 524288 *512k*
* bench_rgw_number_of_objects: 250000
* bench_rgw_number_of_gets: 500000

This will write out 128GB of data into the cluster which depending on your replication strategy could end up
being a lot more. So validate these numbers accordingly. Also keep in mind the size of the clients 
network connection because if you saturate that link the results of the benchmark will not be accurate.

### Running the benchmark
The time it takes to run the benchmark will depend on the size and number of objects selected, 
and it will output logs to */opt/ceph_bench/logs/rgw_benchmark_test.conf.<timestamp>.log*
Besides the normal results the log will store an output of "hummingbird version" as well as the config used.
Currently this benchmark is set up to run automatically in creation of a CephAIO but if
you would like to buy pass the benchmark set `rgw_bench="False"`.   The results will also be
displayed in the ansible output.

NOTE: When running the benchmark on a multinode cluster you must `internal_lb_vip_address` to the address of your rgw auth endpoint

### Sample output
```
Humminbird Version: v1.0.0

Bench Config Used:
[bench]
auth=http://172.29.236.100:8080/auth/v1.0
user=rgwbench:test
key=rgwbenchsecret
concurrency=15 
object_size=256
num_objects=5000
num_gets=10000
delete = yes
auth_version=1.0
policy_name=gold

Hummingbird Benchmark Output:
Hbird Bench. Concurrency: 15. Object size in bytes: 256
PUTs: 5000 @ 313.61/s
  Failures: 0
  Mean: 0.04777s (210.1% RSD)
  Median: 0.04019s
  85%: 0.05609s
  90%: 0.06067s
  95%: 0.06743s
  99%: 0.08686s
GETs: 10000 @ 2642.35/s
  Failures: 0
  Mean: 0.00567s (53.7% RSD)
  Median: 0.00492s
  85%: 0.00837s
  90%: 0.00945s
  95%: 0.01140s
  99%: 0.01662s
DELETEs: 5000 @ 353.94/s
  Failures: 0
  Mean: 0.04232s (37.1% RSD)
  Median: 0.04022s
  85%: 0.05561s
  90%: 0.05999s
  95%: 0.06673s
  99%: 0.08558s
```
