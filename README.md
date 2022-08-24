# Homelab-as-code
Ansible playbook to setup my homelab nodes.

## Assumptions
- Every node runs Debian 11.
- All are part of the Nomad, Consul, Vault cluster.
- Monitoring is done through a Prometheus container running in Nomad: [homelab-nomad](https://github.com/qjvtenkroode/homelab-nomad).
- Ansible user is called 'overseer'
- Terraform is used for volumes and jobs in Nomad: [homelab-terraform](https://github.com/qjvtenkroode/homelab-terraform)

## Improvements / TODO's
- [ ] Make network interface for Consul client and server templates dynamic
- [ ] Create Hashicorp Vault role
- [x] Add Consul retry_join server list
- [ ] Make Consul join/create the cluster automatically through a var
- [ ] Stop Consul, Nomad or Vault before upgrading
- [ ] Vault integration in Nomad with role instead of requiring a root token variable

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
