# Description: homeassistant for selfhosted password management

job "homeassistant" {
    datacenters = ["homelab"]
    group "homeassistant" {
        network {
            port "ui" {
                static = 8123
                to = 8123
            }
        }
        service {
            check {
                interval = "10s"
                timeout = "2s"
                type = "tcp"
            }
            name = "homeassistant"
            port = "ui"
            tags = [
                #"urlprefix-/",
            ]
        }
        task "homeassistant" {
            config {
                image = "ghcr.io/home-assistant/home-assistant:2022.8"
                network_mode = "host"
                ports = ["ui"]
                privileged = true
            }
            driver = "docker"
            env {
                TZ = "Europe/Amsterdam"
            }
            resources {
                cpu = 1024
                memory = 2048
            }
            volume_mount {
                destination = "/config"
                read_only = false
                volume = "homeassistant"
            }
        }
        volume "homeassistant" {
            access_mode = "single-node-writer"
            attachment_mode = "file-system"
            read_only = false
            source = "homeassistant"
            type = "csi"
        }
    }
    type = "service"
}
