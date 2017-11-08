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
run in serial, and output logs to /opt/ceph_fiobench/<test>.<timestamp>.log.
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
