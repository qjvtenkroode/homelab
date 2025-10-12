# Description: cribl for log data management

job "cribl" {
    datacenters = ["homelab"]
    group "cribl" {
        network {
            port "criblui" {
                to = 9000
            }
            port "in_syslog" {
                to = 9514
                static = 9514
            }
        }
        service {
            check {
                interval = "10s"
                timeout = "2s"
                type = "tcp"
            }
            name = "cribl"
            port = "criblui"
            tags = [
                "urlprefix-cribl.qkroode.nl",
            ]
        }
        task "cribl" {
            config {
                image = "cribl/cribl:latest"
                network_mode = "bridge"
                ports = ["criblui","in_syslog"]
                privileged = false
            }
            driver = "docker"
            env {
                CRIBL_VOLUME_DIR = "/opt/cribl/config-volume"
            }
            resources {
                cpu = 1024
                memory = 2048
            }
            volume_mount {
                destination = "/opt/cribl/config-volume"
                read_only = false
                volume = "cribl"
            }
        }
        volume "cribl" {
            access_mode = "single-node-writer"
            attachment_mode = "file-system"
            read_only = false
            source = "cribl"
            type = "csi"
        }
    }
    type = "service"
}
