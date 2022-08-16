resource "nomad_job" "storage-controller" {
    jobspec = file("${path.module}/../homelab-nomad/csi/storage-controller.nomad")
}

resource "nomad_job" "storage-node" {
    jobspec = file("${path.module}/../homelab-nomad/csi/storage-node.nomad")
}

resource "nomad_job" "traefik" {
    jobspec = file("${path.module}/../homelab-nomad/traefik.nomad")
}

resource "nomad_job" "registry" {
    jobspec = file("${path.module}/../homelab-nomad/registry.nomad")
}
