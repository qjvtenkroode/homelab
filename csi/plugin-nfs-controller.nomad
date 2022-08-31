job "plugin-nfs-controller" {
  datacenters = [ "homelab" ]

  group "controller" {
    task "plugin" {
      driver = "docker"

      config {
        image = "mcr.microsoft.com/k8s/csi/nfs-csi:latest" # "csi-driver-nfs:local"

        args = [
          "--endpoint=unix://csi/csi.sock",
          "--nodeid=contoller",
          "--logtostderr",
          "-v=5",
        ]
        network_mode = "host"
        privileged = true
      }

      csi_plugin {
        id = "nfs"
        type = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu = 250
        memory = 128
      }
    }
  }
}
