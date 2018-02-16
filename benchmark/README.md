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

fio_direct_read_test - Direct reads from an rbd device
fio_direct_write_test - Direct writes to an rbd device
fio_rw_mix - Mixture of direct reads and writes to/from an rbd device
fio_test_file_read - Reads from a mounted rbd device with an xfs file system.
fio_test_file_write - Writes to a mounted rbd device with an xfs file system.

Additional tests, with different blocksizes, numjobs and iodepth can be added
using the ``fio_bench_list_extras`` var, and specifying a different vars for the
specific test, for example, if you want to add a test to do direct reads
from an rbd device with 32k blocksize, iodepth 8 and numjobs 4:

```
fio_bench_list_extras:
  - src: "fio_direct_read_test.cfg.j2"
    name: "my_custom_direct_read_test"
    override: "{{ fio_direct_read_test_32k_overrides | default({}) }}"
    blocksize: "32k"
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

Alternatively, you could adjust the ``fio_bench_list`` vars to set the
``run_bench`` var to be on/off, or have a different criteria as needed.

### Benchmark log output
The output of all FIO runs are stored in ``/opt/ceph_bench/logs``, with the name
of the job used to generate the log, along with a ``date_time`` value to ensure
that logs are not overwritten on consecutive runs and can instead be compared.

### Cleaning up a deploy
The cleanup script will unmount, unmap and remove the rbd image, as well as
delete the fiobench pool if "fiobench_pool_name" is not specified.
