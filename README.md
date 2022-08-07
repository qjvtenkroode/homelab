# Homelab-as-code
Ansible playbook to setup my homelab nodes.

## Assumptions
- Every node runs Rocky Linux.
- All are part of the Nomad, Consul, Vault cluster.
- Monitoring is done through a Prometheus container running in Nomad.
- Ansible user is called 'overseer'

## Improvements / TODO's
- [ ] Make network interface for Consul client and server templates dynamic
- [ ] Create Hashicorp Vault role
- [x] Add Consul retry_join server list
- [ ] Make Consul join/create the cluster automatically through a var
- [ ] Stop Consul, Nomad or Vault before upgrading

## Playbooks

### Deploy the backend
First fill an `inventory.yml` with your minions (nodes) and overwrite any variables that are needed:
    - consul_datacenter 
    - consul_type
    - nomad_datacenter
    - nomad_type

Then run the playbook:
`ansible-playbook playbook-deploy-backend.yml -i inventory.yml -u overseer`

Keep in mind that the first time running this playbook it is still needed to join the consul cluster together with a `consul join <node1> <node2> <node3>`

### Deploy a Nomad job
Deploying a job doesn't need an inventory, it runs from localhost. Run the playbook and add additional variables that contain the job name:
`ansible-playbook playbook-deploy-job.yml -e "{deploy_job: [abc,xyz], nomad_leader: example.com}"`

The extra-vars have to be in JSON format for the loop to work an be able to deploy multiple jobs at once.
