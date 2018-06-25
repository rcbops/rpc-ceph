# Documentation for the rpc-ceph project

**ALL of the files for the rpc-ceph project have been moved to https://github.com/rcbops/privatecloud-docs/tree/master/doc/rpc-ceph-internal**

**DO NOT put any documentation or reference material in this directory**


## To View the Official Documents
The rpc-ceph documents are for internal use only and require you to be on the rackspace network 
or logged into the Rackspace VPN.

Internal documentation is published at [pages.github.rackspace.com](https://pages.github.rackspace.com/rpc-internal/docs-rpc/master/rpc-ceph-internal/index.html#rpc-ceph-internal) 


## General Information 


### What format are the documents in?
Following the Rackspace Documenation Team's guidelines, all files are in reStructuredText format `.rst`.


### Where did the old documentation go?
All the previous documentation is still available as it was simply moved to https://github.com/rcbops/privatecloud-docs/tree/master/doc/rpc-ceph-internal


### How do I submit additions and modifications to the project documents

## Set up a local working environment
Create your own fork of the document repository `https://github.com/rcbops/privatecloud-docs`

Clone the new fork to a local machine
```bash
git clone git@github.com:<username>/privatecloud-docs.git
```

Create a remote reference named **upstream**
```bash
git remote add upstream git@github.com:rcbops/privatecloud-docs.git
```

Verify the repository and references are correct
```bash
cd privatecloud-docs
git checkout master
git fetch upstream
git merge upstream/master
git push origin master
```


### Submit the Additions and Modifications for Review
Push our committed changed to your fork
```bash
git push origin <branch name>
```

Create a Pull request with main repository `https://github.com/rcbops/privatecloud-docs`
Make sure to:
* Start the subject with CEPHSTORA-<ID>
* Follow the contribution guidelines concerning release notes if necessary
* Submit for review
  * TODO - work up a list of reviewers (Support, Service/Delivery, Storage Engineering, Product, Documentation Team)



