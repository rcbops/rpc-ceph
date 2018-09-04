

## How to do an rpc-ceph release

In the repo [releases](https://github.com/rcbops/releases) the following things need to be done.   

### Review the current RE Process
Before you begin it's a good idea to review the current process and look for any changes. You can find the Release process [here](https://rpc-openstack.atlassian.net/wiki/spaces/RE/pages/19005457/RE+for+Projects#REforProjects-Release)


### Edit the release file 
In the file **releases/components/rpc-ceph.yml**, under the `versions section` add in the next release version and it's sha

```
is_product: true
name: rpc-ceph
releases:
- series: master
  versions:
  - sha: 09149f9c95b3cc9286dd343bcfe15de86ebf1f18
    version: 1.1.5
```

### Create a Pull request.  
Create a pull request and have it reviewed by your team members and the folks at RE.


### Build the release
After all the checks have finished except **CIT/release** and it as been reviewd put `:shipit:` in a comment inside the open pull request.


### Merge the Pull request
Nothing needs to be done. When the RELEASE_ jobs finish running and the release is cut, the PR will merge automatically


### Example Pull request
[Successful Pull Request](https://github.com/rcbops/releases/pull/26)

