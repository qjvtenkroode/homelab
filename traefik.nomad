# Description: Treafik as frontend proxy for all exposed services within Nomad cluster

job "traefik-test" {
    datacenters = ["testing"]
    type = "service"

    group "traefik" {
        network {
            port "http" {
                static = 80
                to = 80
            }
            port "https" {
                static = 443
                to = 80
            }
            port "ui" {
                static = 8080
                to = 80
            }
        }
        service  {
            check {
                name = "traefik reachable check"
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
            port = "ui"
            tags = [
                "traefik.enable=true",
                "traefik.frontend.entryPoints=http,https"
            ]
            
        }
        task "traefik" {
            driver = "podman"
            config {
                image = "traefik:v2.3"
                ports = ["http", "https", "ui"]
                env = [
                    "--api.insecure=true"
                ]
            }
            resources {
                cpu = 100
                memory = 64
            }
        }
    }
}
