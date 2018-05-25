# Checking for config changes

The rpc-ceph project provides the ability to test for configuration differences between rpc-ceph and a running ceph-cluster
that was previously deployed by either ceph-ansible or another version of rpc-ceph.  Once you have bootstrapped rpc-ceph
and configured your variable overrides to match the values of your running cluster, you can run the
`check-for-config-changes.yml` playbook to check and see if any values will change if you were to apply rpc-ceph.

## Running check-for-config-changes.yml

```
ceph-ansible-playbook -i <inventory> playbooks/check-for-config-changes.yml
```

## Ceph Config Changes

For each node in your ceph cluster a new ceph configuration will be generated in a temporary location and compared
against your current ceph config file.  The result will be a dict of config that has been 'ADDED' in the new config,
config that has 'CHANGED' from the old config to the new config and config that has been 'REMOVED' in the new config.

### ADDED Config

Config that has been 'added' is config that you were not setting before and were just taking the default.  The
assumption here is that the new config value is different from the default value.  For each added config you will
need to decide whether you want to accept the new value or update your variables files to use the old value. To
unset one of rpc-ceph's default values and continue to use Ceph's default value you will want to add the
configuration setting to `ceph_conf_overrides_extra` dict with a value of `{{ omit }}`.

### CHANGED Config

Config that has 'changed' will be listed with what the 'current value' is according to the ceph.conf file and what the
'new value' will be when rpc-ceph is applied.  You can either accept the new value or update the variables file to
continue to use the old value.  When you run `deploy-ceph.yml` or `deploy.yml` playbook any configuration changes
reported by this tool will be applied including service restarts if changes are made.

### REMOVED Config

Config that has been 'removed' is config that exists in the current ceph.conf file and is not defined in the new
config file.  If you want to keep this configuration moving forward simply add it to the variables file.  In the
example below in the sample output with config changes section you would need to add to the following:

```
ceph_conf_overrides_extra:
  global:
    debug_asok: "0/0"
```

### Sample Output with changes that will cause ceph service restarts

```
TASK [debug] ***********************************************************************************************************************************************************************************************
ok: [ceph-mbv-test-stor-1] => {
    "ceph_comp.changes": {
        "ADDED": {
            "global": {
                "mon_osd_down_out_interval": "900",
                "osd_pool_default_pg_num": "32",
                "osd_pool_default_pgp_num": "32"
            },
            "osd": {
                "filestore_max_sync_interval": "10",
                "filestore_merge_threshold": "40",
                "osd_snap_trim_sleep": "0.1"
            }
        },
        "CHANGED": {
            "client.rgw.ceph-mbv-test-stor-1": {
                "rgw frontends": {
                    "current value": "civetweb port=172.20.41.77:8080 num_threads=100",
                    "new value": "civetweb port=172.20.41.77:8080 num_threads=8192"
                }
            },
            "client.rgw.ceph-mbv-test-stor-2": {
                "rgw frontends": {
                    "current value": "civetweb port=172.20.41.140:8080 num_threads=100",
                    "new value": "civetweb port=172.20.41.140:8080 num_threads=8192"
                }
            },
            "client.rgw.ceph-mbv-test-stor-3": {
                "rgw frontends": {
                    "current value": "civetweb port=172.20.41.168:8080 num_threads=100",
                    "new value": "civetweb port=172.20.41.168:8080 num_threads=8192"
                }
            },
            "client.rgw.ceph-mbv-test-stor-4": {
                "rgw frontends": {
                    "current value": "civetweb port=172.20.41.169:8080 num_threads=100",
                    "new value": "civetweb port=172.20.41.169:8080 num_threads=8192"
                }
            }
        },
        "REMOVED": {
            "global": {
                "debug_asok": "0/0"
        }
    }
}
```

### Sample Output with no changes and no restarts

```
TASK [debug] ***********************************************************************************************************************************************************************************************
ok: [ceph-mbv-test-stor-1] => {
    "ceph_comp.changes": {
        "ADDED": {},
        "CHANGED": {},
        "REMOVED": {}
    }
}
```


## Sysctl Changes

For each node in your ceph cluster a sysctl file will be generated in a temporary localtion and comapred against
the current sysctl settings in the /etc/sysctl.d/ceph-tuning.conf file.  The result will be a dict of config that
has been 'ADDED' in the new config, config that has 'CHANGED' from the old config to the new config and config
that has been 'REMOVED' in the new config.  

### ADDED Config

Sysctl settings that have been 'added' are changes that will be applied to your system unless you overrite the
`os_tuning_params` dict to not contain those configuration values.

### CHANGED Config

Sysctl settings that have been 'changed' will display the 'current value' that is currently set and the
'new value' that the setting will be updated to.  Ensure the value you want is defined in the `os_tuning_params`
dict.

### REMOVED Config

Config that is being 'removed' is config that was set and is know longer listed in the `os_tuning_params` dict.
When config is removed it will not be unset until a reboot occurs.

### Sample Output with changes that will cause ceph service restarts

```
TASK [debug] ***********************************************************************************************************************************************************************************************
ok: [ceph-mbv-test-stor-1] => {
    "sysctl_comp.changes": {
        "ADDED": {
            "sysctl": {
                "net.core.optmem_max": "40960", 
                "net.core.rmem_default": "56623104", 
                "net.core.rmem_max": "56623104", 
                "net.core.somaxconn": "8192", 
                "net.core.wmem_default": "56623104", 
                "net.core.wmem_max": "56623104", 
                "net.ipv4.tcp_max_syn_backlog": "4096", 
                "net.ipv4.tcp_rmem": "4096 87380 56623104", 
                "net.ipv4.tcp_slow_start_after_idle": "0", 
                "net.ipv4.tcp_wmem": "4096 87380 56623104", 
                "net.netfilter.nf_conntrack_max": "1048576", 
                "vm.dirty_background_ratio": "3", 
                "vm.dirty_ratio": "10", 
                "vm.vfs_cache_pressure": "20"
            }
        }, 
        "CHANGED": {
            "sysctl": {
                "vm.swappiness": {
                    "current value": "10", 
                    "new value": "0"
                }
            }
        }, 
        "REMOVED": {
            "sysctl": {
                "vm.min_free_kbytes": "67584", 
                "vm.zone_reclaim_mode": "0"
            }
        }
    }
}
```

### Sample Output with no changes and no restarts
```
TASK [debug] ***********************************************************************************************************************************************************************************************
ok: [ceph-mbv-test-stor-1] => {
    "sysctl_comp.changes": {
        "ADDED": {},
        "CHANGED": {},
        "REMOVED": {}
    }
}
```

## Transparent Hugepages

This check will verify that your value for `disable_transparent_hugepage` matches from your current cluster to your
future configuration.  If the values are the same both Transparent hugepages tasks will be skipped.  If there is a
mismatch, one of the steps will display the config you need to add to fix it.  If you want to change the setting
you can disregard the message and take no action.

```
TASK [Transparent hugepages was enabled] *******************************************************************************************************************************************************************

TASK [Transparent hugepages was disabled] ******************************************************************************************************************************************************************
ok: [ceph-mbv-test-stor-1] => {
    "msg": "Your config will change  trasparent_hugepage to enabled.  Set disable_transparent_hugepage: true"
}
ok: [ceph-mbv-test-stor-2] => {
    "msg": "Your config will change  trasparent_hugepage to enabled.  Set disable_transparent_hugepage: true"
}
ok: [ceph-mbv-test-stor-3] => {
    "msg": "Your config will change  trasparent_hugepage to enabled.  Set disable_transparent_hugepage: true"
}
ok: [ceph-mbv-test-stor-4] => {
    "msg": "Your config will change  trasparent_hugepage to enabled.  Set disable_transparent_hugepage: true"
}

PLAY RECAP *************************************************************************************************************************************************************************************************
ceph-mbv-test-stor-1       : ok=66   changed=3    unreachable=0    failed=0   
ceph-mbv-test-stor-2       : ok=60   changed=3    unreachable=0    failed=0   
ceph-mbv-test-stor-3       : ok=60   changed=3    unreachable=0    failed=0   
ceph-mbv-test-stor-4       : ok=32   changed=3    unreachable=0    failed=0   
```

