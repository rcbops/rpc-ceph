# Getting started with Documentation
This document provides a guide on how to build and contribute to the documentation. We are trying to follow the same format and process used in the RPC [k8s](https://github.com/rcbops/kubernetes-installer) Project.

An effort was made to reduce the impact that sphinx would add due to the configuration and additional files that are added as part of the build process. Not to mention that sphinx out of the box only support `reStructuredText`.  This implementation adds support for `markdown` to contribute to the documentation.  The addition of sphinx puts us in-line with the rest of the RPC organization and it gives us the ability to generate internal and external documentation from the same repository; with the addition of a simple environment variable at build time.

All external documentation is in directories that are postfixed `-external` and anything that is internal is postfixed with `-internal`.

### Adding a new internal section
If you wanted to add a new section that is meant to be for internal use only or want to keep it internal for sometime create a new directory and postfix `-internal` and update the `conf.py` file and add your directory to the list `exclude_patterns.extend([])`

## Building the documentation
To build the documentation is as simple as running the following command. The execution  will result in the creation of a directory named `_build`.

### Build internal and external documentation
From with in the `docs` directory execute the following command:
```
make docs
```

### Only build external documentation
The following command will only build customer/public facing documentation.
```
make docs-external
```

### View newly built documentation
If you are on `osx` you can view the documentation by executing the following:

from with in the `rpc-ceph/docs directory`
```
open _build/html/index.html
```

from with in the `rpc-ceph directory`
```
open rpc-ceph/_build/html/index.html
```

## Where did the old documentation go?
All the previous documentation is still available as it was simply moved to a different directory. The following maps the new to the old.

| Original Location | New Location |
| :--- | :--- |
| rgw_setup.md | ops-internall/rgw_setup.md |
| rpc-ceph-install.md | ops-internal/rpc-ceph-install.md |
| deployment-scenariosi/ | ops-internal |
| deployment-scenarios/CephNodeAddition.txt | ops-internal/ceph-node-addition.md |
| deployment-scenarios/CephNodeAdditionJewel.txt | ops-internal/ceph-node-addition-Jewel.md |
| deployment-scenarios/Ceph_Standalone_Install.md | ops-internal/ceph-standalone-install.md |
| deployment-scenarios/RollingUpdates.yml | ops-internal/rollingUpdates.md |

# Unsure about this section 

## Publish the documentation

The Rackspace RPC rpc-ceph documentation is published in the
following locations:

* Internal documentation is published at [pages.github.rackspace.com](https://pages.github.rackspace.com/rpc-internal/docs-rpc-mk8s).
* External documentation is published at [developer.rackspace.com](https://developer.rackspace.com) (to
  be published with GA).

While the [Deconst](https://github.com/deconst) publishing tool triggers the
external documentation publishing job automatically after a PR is merged,
internal publishing requires a few additional manual steps.

## Publish the internal documentation

Since Deconst can only publish documentation stored in a public repository,
we use repository mirroring to publish the internal documentation. The internal
repository at https://github.rackspace.com/rpc-internal/docs-rpc-mk8s
mirrors the content of the `_build/html` directory. From
the internal repository the content is automatically published at
[pages.github.rackspace.com](https://pages.github.rackspace.com/rpc-internal/docs-rpc-mk8s).

To publish the internal content, complete the following steps:

1. Set up your repository for publishing.

   1. Add an internal repository as a remote:

      ```git remote add internal git@github.rackspace.com:rpc-internal/docs-rpc-mk8s.git```

   1. Verify your remotes:

      ```git remote -v```

      *Example of output:*

      ```
      internal   git@github.rackspace.com:rpc-internal/docs-rpc-mk8s.git (fetch)
      internal   git@github.rackspace.com:rpc-internal/docs-rpc-mk8s.git (push)
      origin   git@github.com:svetkars/kubernetes-installer.git (fetch)
      origin   git@github.com:svetkars/kubernetes-installer.git (push)
      upstream   git@github.com:rcbops/kubernetes-installer.git (fetch)
      upstream   git@github.com:rcbops/kubernetes-installer.git (push)
      ```

   1. Update your remotes:

      ```git remote update```

   1. Create a local branch called `gh-pages` and set it to track
      internal/gh-pages:

      ```git branch gh-pages --track internal/gh-pages```

1. Publish your content:

   1. Clone or update stable branches starting from branch 0.6.x:

      ```
      git checkout <branch>
      git fetch upstream <branch>
      git pull upstream <branch>
      ```

   1. Switch back to the master branch.
   1. Delete the contents of `docs/_build/html`.
   1. Build the versioned web-site:

      ```sphinx-versioning -l docs/conf.py build docs/ docs/_build/html```

      Sphinx builds the content for the whitelisted branches.

   1. Verify  that your local branches do not appear in the build by openning
      the `_build/html/index.html` file in your web browser.

   1. Save the contents of `_build/html` in a directory outside of the
      `kubernetes-installer` repository.
   1. Switch to the `gh-pages` branch.
   1. Paste the contents of the `_build/html` directory in
      `kubernetes-installer`.
   1. Push your changes to the internal `gh-pages` branch:

      ```git push internal gh-pages```

1. Verify your changes in the `gh-pages` branch of the
   [rpc-internal/docs-rpc-mk8s](https://github.rackspace.com/rpc-internal/docs-rpc-mk8s/tree/gh-pages)
   repository.
1. Verify your changes at [pages.github.rackspace.com](https://pages.github.rackspace.com/rpc-internal).

### Add a new branch for publishing

If you want to publish a new branch, you need to add that branch to the
`shpinxcontrib-versioning` white list in the `docs/conf.py` file. Since
`sphinxcontrib-versioning` reads the conf.py from your fork, you need to merge
the changes to the `docs/conf.py` file with the correct list of branches to
upstream master and to the upstream branch you want to pubslish.

**To add a new branch for publishing:**

1. Open the `conf.py` file for editing.
1. Add the new branch to the `scv_whitelist_branches` list.

   **Example:**

   ```
   scv_whitelist_tags = ('0.6.0', '0.6.1', '0.7.0',
                         '0.8.0', '0.8.1', '0.8.2', '0.9.0')
   ```

   Add `0.10.x`:

   ```
   scv_whitelist_tags = ('0.6.0', '0.6.1', '0.7.0',
                         '0.8.0', '0.8.1', '0.8.2', '0.9.0', '0.10.x')
   ```

1. Submit a PR to merge your changes to the upstream repository.
1. Cherry pick your changes to the branch you want to pubish.
1. Publish documentation as described above.
