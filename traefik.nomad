# Description: Treafik as frontend proxy for all exposed services within Nomad cluster

job "test-traefik" {
    datacenters = ["testing"]
    type = "service"

    group "traefik" {
        network {
            port "http" {
                static = 80
                to = 80
            }
            port "ui" {
                static = 8080
                to = 8080
            }
        }
        service  {
            check {
                name = "traefik reachable check"
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
            name = "traefik-test"
            port = "ui"
            tags = [
                "traefik.enable=true",
                "traefik.frontend.entryPoints=http"
            ]
        }
        task "traefik" {
            driver = "podman"
            config {
                image = "traefik:v2.6"
                ports = ["http", "ui"]
                args = [
                    "--api.insecure=true",
                    "--metrics.prometheus=true",
                    "--metrics.prometheus.addrouterslabels=true",
                    "--entryPoints.web.address=:80",
                    "--providers.consulcatalog",
                    # filter down to only test servics through a prefix
                    "--providers.consulcatalog.prefix=test-traefik",
                    "--providers.consulcatalog.endpoint.address=consul.service.consul:8500",
                    "--providers.consulcatalog.endpoint.datacenter=homelab",
                    "--providers.consulcatalog.exposedByDefault=false"

                ]
            }
            resources {
                cpu = 100
                memory = 64
            }
        }
    }
}
