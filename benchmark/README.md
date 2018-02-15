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

### Test options
FIO options can be set using config_template overrides for each test.
The 5 test scenarios and their corresponding overrides vars are:
fio_direct_read_test - fio_direct_read_test_overrides
fio_direct_write_test - fio_direct_write_test_overrides
fio_rw_mix - fio_rw_mix_overrides
fio_test_file_read - fio_test_file_read_overrides
fio_test_file_write - fio_test_file_write_overrides

### Running tests
There are 5 test scenarios based on the document linked above. These are
meant to represent tests for SSDs and SATA devices. By default all 5 tests will
run in serial, and output logs to /opt/ceph_bench/<test>.<timestamp>.log.
This means multiple test runs will generate multiple logs. Additionally, the log
will store an output of "fio --version" as well as the config used in the test.
If you would like to run only the sata tests set "ssd_bench=False", or for only
ssd tests set "sata_bench=False".

SATA tests:
fio_rw_mix
fio_direct_read_test
fio_direct_write_test

SSD Tests:
fio_test_file_read
fio_test_file_write

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

* bench_rgw_concurrency:  number of concurrent operations
* bench_rgw_object_size:   size of the object in bytes used in the benchmark 
* bench_rgw_number_of_objects:  number of objects placed in the system 
* bench_rgw_number_of_gets: number of get requests performed

When choosing the concurrency setting keep in mind the network throughput available on the client boxes. 
When choosing the object size and number settings keep in mind that multiple replicas of the object will 
written into the system so check the clusters available space.   

### Running the benchmark
The time it takes to run the benchmark will depend on the size and number of objects selected, 
and it will output logs to */opt/ceph_bench/logs/rgw_benchmark_test.conf.<timestamp>.log*
Besides the normal results the log will store an output of "hummingbird version" as well as the config used.
Currently this benchmark is set up to run automatically in creation of a CephAIO but if
you would like to buy pass the benchmark set `rgw_bench="False"`.   The results will also be
displayed in the ansible output.

### Sample output
```
Humminbird Version: v1.0.0

Bench Config Used:
[bench]
auth=http://172.29.236.100:8080/auth/v1.0
user=testuser:swift
key=swiftsecret
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