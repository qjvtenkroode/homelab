resource "nomad_job" "plugin-nfs-controller" {
    jobspec = file("${path.module}/../homelab-nomad/csi/plugin-nfs-controller.nomad")
}

resource "nomad_job" "plugin-nfs-node" {
    jobspec = file("${path.module}/../homelab-nomad/csi/plugin-nfs-node.nomad")
}

resource "nomad_job" "fabio" {
    jobspec = file("${path.module}/../homelab-nomad/fabio.nomad")
}

resource "nomad_job" "registry" {
    jobspec = file("${path.module}/../homelab-nomad/registry.nomad")
}

resource "nomad_job" "qkroode" {
    jobspec = file("${path.module}/../homelab-nomad/qkroode.nomad")
}

resource "nomad_job" "vaultwarden" {
    jobspec = file("${path.module}/../homelab-nomad/vaultwarden.nomad")
}
