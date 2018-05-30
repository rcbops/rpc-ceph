# Adding a New Ceph Node into a Jewel Cluster 

## MAINTENANCE PREP

### Maintenance objective: 
1. Add new nodes to existing ceph environment (jewel or hammer only)
   1. What should we check to confirm the solution is functioning as expected? 
   * Ceph is HEALTH_OK state.

2. Departments involved: RPC

3. Owning department: RPC

4. Amount of time estimated for maintenance: 2 hours (36 hours monitoring)

5. Pre-Maintenance Steps:

   1. **RPC** Log in on the Ceph Deployment node
```bash
 # ht <ceph_deployment_node>
```

   2. **RPC** Add new nodes to /etc/hosts
```bash
 # vim /etc/hosts
```

   3. **RPC** Ensure that the ssh keys from the Ceph deployment node have been added.
   * This can be done with ssh 

6. Maintenance Steps:

   1. **RPC** Configure RBA 36hr supression on the following nodes:
   * ceph nodes

   2. **RPC** Update ticket with notification that maintenance is beginning.

   3. **RPC** Log in on the Ceph Deployment node 
   ```bash
    # ht <ceph_deployment_node> 
   ```

   4. **RPC** Validate cluster health
    ```bash
    # ceph health
    ```
    **if ceph health is NOT `HEALTH_OK`, DO NOT PROCEED**

   5. **RPC** Set flags in Ceph environment
   ```bash
    # ceph osd set noout
    # ceph osd set noin
    # ceph osd set noup
    # ceph health
   ``` 
   **ceph health should now report as `HEALTH_WARN`**
  
   6. **RPC** Backup the Ceph inventory file
   ```bash
    # cd /opt/rpc-ceph
    # cp ceph_inventory ceph_inventory.bak
   ```

  7. **RPC** Add new nodes to the correct sections in /opt/ceph-ansible/ceph_inventory
  ```bash
    # vim ceph_inventory
  ```

  8. **RPC** Check connectivity to the new nodes
  ```bash
    # ceph-ansible -i ceph_inventory -m ping
  ```

  9. **RPC** Take note of the highest numbered osd id
  ```bash
    # ceph osd ls
  ```

  10. **RPC** Run the Ceph-Ansibleplaybook
      *NOTE:* This will take a while, please run this in a tmux session
  ```bash
    # tmux new -s <ticket num>
    # tmux split-window -h
    # watch -n5 ceph -s
  ```
    Hit (ctrl-b + o)
  ```bash
    # ceph-ansible-playbook -i ceph_inventory playbooks/deploy-ceph.yml --forks 10
  ```

  11. **RPC** Once playbook finishes, ensure new osds have been added.
  ```bash
    # ceph osd tree
  ```

  12. - <RPC> Set the new node(s) crush weight to 0
  ```bash
    # TEMPLATE # 
    # for osd in $(seq <start osd> 1 <end osd>); do ceph osd crush reweight osd.$osd 0; ceph osd reweight $osd 1; done

    # for osd in $(seq 410 1 509); do ceph osd crush reweight osd.$osd 0; ceph osd reweight $osd 1; done
  ```
  **Do NOT continue until the cluster is done rebalancing from the playbook's execution. Use your second window to watch the cluster.**

  13. **RPC** Perform Ceph health check and unset flags
  ```bash
    # ceph health
  ```
  **ceph health should now report as 'HEALTH_WARN'**
  ```bash
    # ceph osd unset noout
    # ceph osd unset noin
    # ceph osd unset noup
    # ceph health
  ```
  **if ceph health is not `HEALTH_OK`, escalate**

  14. **RPC** Retrieve a new MAAS session token with the following script on *your* local machine
  ```bash
    # git clone https://github.com/rsoprivatecloud/scripts.git
    # cd scripts
    # python maas-cloud-token.py <sso> <account num>
  ```

  15. **RPC** Set this token in /etc/openstack_deploy/maas_variables_overrides.yml
  ```bash
    # sed -i.bak '/maas_auth_token:.*/d' /etc/openstack_deploy/maas_variables_overrides.yml
    # sed -i.bak 's/maas_auth_token:.*/maas_auth_token: <maas token>/' /etc/openstack_deploy/maas_variables_overrides.yml
  ```

  16. **RPC** Add nodes to the maas inventory
  ```bash
    # cd /etc/openstack_deploy
    # vim maas_inventory
  ```

  17. **RPC** Run the MaaS playbook
  ```bash
    # cd /opt/rpc-maas
    # ansible-playbook -i /etc/openstack_deploy/maas_inventory site.yml
  ```

  18. **RPC** Increase the weights of the new osds. This will take awhile. Each increase will cause a rebalance.
  ```bash
    # Template #
    # for weight in $(seq 0.01 0.01 <final weight>); do for osd in $(seq <start osd> 1 <end osd>); do ceph osd crush reweight osd.$osd $weight; sleep 10; done; done

    # for weight in $(seq 0.01 0.01 5.5); do for osd in $(seq 410 1 509); do ceph osd reweight osd.$osd $weight; sleep 10; done; done
  ```
  **Do not continue until this step is finished**

  19. **RPC** Validate cluster health
  ```bash
    # ceph health
  ```
  **if ceph health is not `HEALTH_OK`, escalate**

  20. **RPC** Ensure all new monitoring checks are green. 

  21. **RPC** Notify customer maintenance is complete and end the supression. 

7. Escalation procedure  **DO NOT ABORT MAINTENANCE UNTIL FOLLOWED**
   
   1. No escalation procedures

8. Rollback plan  **REQUIRED**

  1. Replace failing hardware with parts from inventory until health is **OK**.

9. Post Maintenance Notification 

* *Success* Update ticket
* *Failure* Update ticket