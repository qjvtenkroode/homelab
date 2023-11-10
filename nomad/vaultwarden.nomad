# Description: Vaultwarden for selfhosted password management

job "vaultwarden" {
    datacenters = ["homelab"]
    type = "service"

    group "vaultwarden" {
        network {
            port "http" {
                to = 80
            }
            port "websocket" {
                to = 3012
            }
        }
        service {
            check {
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
            name = "vaultwarden"
            port = "http"
            tags = [
                "urlprefix-warden.qkroode.nl/",
                "urlprefix-warden.qkroode.nl/notifications/hub"
            ]
        }
        task "vaultwarden" {
            driver = "docker"
            config {
                image = "docker.io/vaultwarden/server:1.25.2"
                ports = ["http", "websocket"]
            }
            env {
                DOMAIN = "https://warden.qkroode.nl"
                SIGNUPS_ALLOWED = false
                WEBSOCKET_ENABLED = true
                I_REALLY_WANT_VOLATILE_STORAGE=true
            }
            resources {
                cpu = 200
                memory = 64
            }
            volume_mount {
                volume = "vaultwarden"
                destination = "/data/"
                read_only = false
            }
        }
        volume "vaultwarden" {
            type = "csi"
            read_only = false
            source = "vaultwarden"
            access_mode = "single-node-writer"
            attachment_mode = "file-system"
        }
    }
}
