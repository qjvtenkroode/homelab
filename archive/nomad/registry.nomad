# Description: private docker registry

job "registry" {
    datacenters = ["homelab"]
    type = "service"

    group "registry" {
        network {
            port "registry" {
                to = 5000
                static = 5000
            }
        }
        service  {
            check {
                name = "registry reachable check"
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
            name = "registry"
            port = "registry"
            tags = [
                "urlprefix-registry.qkroode.nl/"
            ]
        }
        task "registry" {
            driver = "docker"
            config {
                image = "docker.io/library/registry:2.8.1"
                ports = ["registry"]
            }
            resources {
                cpu = 100
                memory = 64
            }
            volume_mount {
                volume = "registry"
                destination = "/var/lib/registry"
                read_only = false
            }
        }
        volume "registry" {
            type = "csi"
            read_only = false
            source = "registry"
            access_mode = "single-node-writer"
            attachment_mode = "file-system"
        }
    }
}
