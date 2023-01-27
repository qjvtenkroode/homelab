data "nomad_plugin" "nfs" {
  plugin_id        = "nfs"
  wait_for_healthy = true
  depends_on       = [nomad_job.plugin-nfs-controller,nomad_job.plugin-nfs-node]
}

resource "nomad_volume" "homeassistant" {
  type                  = "csi"
  plugin_id             = "nfs"
  volume_id             = "homeassistant"
  name                  = "homeassistant"
  external_id           = "homeassistant"
  deregister_on_destroy = true
  depends_on            = [data.nomad_plugin.nfs]

  capability {
    access_mode           = "single-node-writer"
    attachment_mode       = "file-system"
  }

  mount_options {
    fs_type = "nfs"
  }

  context = {
    server             = "truenas.qkroode.nl"
    share              = "/mnt/homelab/csi/vols/homeassistant"
  }
}

resource "nomad_volume" "prometheus" {
  type                  = "csi"
  plugin_id             = "nfs"
  volume_id             = "prometheus"
  name                  = "prometheus"
  external_id           = "prometheus"
  deregister_on_destroy = true
  depends_on            = [data.nomad_plugin.nfs]

  capability {
    access_mode           = "single-node-writer"
    attachment_mode       = "file-system"
  }

  mount_options {
    fs_type = "nfs"
  }

  context = {
    server             = "truenas.qkroode.nl"
    share              = "/mnt/homelab/csi/vols/prometheus"
  }
}

resource "nomad_volume" "registry" {
  type                  = "csi"
  plugin_id             = "nfs"
  volume_id             = "registry"
  name                  = "registry"
  external_id           = "registry"
  deregister_on_destroy = true
  depends_on            = [data.nomad_plugin.nfs]

  capability {
    access_mode           = "single-node-writer"
    attachment_mode       = "file-system"
  }

  mount_options {
    fs_type = "nfs"
  }

  context = {
    server             = "truenas.qkroode.nl"
    share              = "/mnt/homelab/csi/vols/registry"
  }
}

resource "nomad_volume" "vaultwarden" {
  type                  = "csi"
  plugin_id             = "nfs"
  volume_id             = "vaultwarden"
  name                  = "vaultwarden"
  external_id           = "vaultwarden"
  deregister_on_destroy = true
  depends_on            = [data.nomad_plugin.nfs]

  capability {
    access_mode           = "single-node-writer"
    attachment_mode       = "file-system"
  }

  mount_options {
    fs_type = "nfs"
  }

  context = {
    server             = "truenas.qkroode.nl"
    share              = "/mnt/homelab/csi/vols/vaultwarden"
  }
}
