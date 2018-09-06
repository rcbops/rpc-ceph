Contributing to rpc-ceph
==========================

Commit Guidelines
-----------------
- All commits should include a sensible subject that includes the linked JIRA issue, if one exists.
- All commits should include a body that explains the fix.
- When a commit has an upgrade impact, introduces a new feature, or contains a change that opertors should know about, a release note should be added to the commit.
  - This can be done using the **reno** tool (**pip install reno**)
  - Refer to https://docs.openstack.org/reno/latest/user/usage.html for more information on using reno.
- Where sensible, squashing commits such that one commit fixes one issue is recommended.
  - Refer to https://github.com/todotxt/todo.txt-android/wiki/Squash-All-Commits-Related-to-a-Single-Issue-into-a-Single-Commit for more information
- Make sure ansible-lint job is successful.
