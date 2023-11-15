resource "nomad_job" "plugin-nfs-controller" {
    jobspec = file("${path.module}/../nomad/csi/plugin-nfs-controller.nomad")
}

resource "nomad_job" "plugin-nfs-node" {
    jobspec = file("${path.module}/../nomad/csi/plugin-nfs-node.nomad")
}

resource "nomad_job" "fabio" {
    jobspec = file("${path.module}/../nomad/fabio.nomad")
}

resource "nomad_job" "registry" {
    jobspec = file("${path.module}/../nomad/registry.nomad")
    depends_on = [nomad_volume.registry]
}

resource "nomad_job" "cribl" {
    jobspec = file("${path.module}/../nomad/cribl.nomad")
    depends_on = [nomad_volume.cribl]
}

resource "nomad_job" "qkroode" {
    jobspec = file("${path.module}/../nomad/qkroode.nomad")
    depends_on = [nomad_job.registry]
}

resource "nomad_job" "vaultwarden" {
    jobspec = file("${path.module}/../nomad/vaultwarden.nomad")
    depends_on = [nomad_volume.vaultwarden]
}

resource "nomad_job" "homeassistant" {
    jobspec = file("${path.module}/../nomad/homeassistant.nomad")
    depends_on = [nomad_volume.homeassistant]
}

#resource "nomad_job" "prometheus" {
#    jobspec = file("${path.module}/../nomad/monitoring/prometheus.nomad")
#    depends_on = [nomad_volume.prometheus]
#}

resource "nomad_job" "photocatalog" {
    jobspec = file("${path.module}/../nomad/photoprism.nomad")
}

resource "nomad_job" "mqtt" {
    jobspec = file("${path.module}/../nomad/mqtt.nomad")
}
