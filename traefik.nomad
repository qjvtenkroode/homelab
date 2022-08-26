# Description: Treafik as frontend proxy for all exposed services within Nomad cluster

job "traefik" {
    datacenters = ["homelab"]
    type = "system"

    group "traefik" {
        network {
            port "http" {
                static = 80
                to = 80
            }
            port "https" {
                static = 443
                to = 443
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
            name = "traefik"
            port = "ui"
            tags = [
                "traefik.enable=true",
                "traefik.frontend.entryPoints=http"
            ]
        }
        task "traefik" {
            driver = "podman"
            config {
                image = "docker.io/library/traefik:v2.6"
                ports = ["http", "https", "ui"]
                args = [
                    "--accesslog=true",
                    "--api.insecure=true",
                    "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=digitalocean",
                    "--certificatesresolvers.letsencrypt.acme.dnschallenge.delaybeforecheck=0",
                    "--certificatesresolvers.letsencrypt.acme.email=qjv.tenkroode@gmail.com",
                    "--certificatesresolvers.letsencrypt.acme.storage=acme.json",
                    "--metrics.prometheus=true",
                    "--metrics.prometheus.addrouterslabels=true",
                    "--entryPoints.web.address=:80",
                    "--entryPoints.websecure.address=:443",
                    "--providers.consulcatalog",
                    "--providers.consulcatalog.prefix=traefik",
                    "--providers.consulcatalog.endpoint.address=consul.service.consul:8500",
                    "--providers.consulcatalog.endpoint.datacenter=homelab",
                    "--providers.consulcatalog.exposedByDefault=false"

                ]
            }
            resources {
                cpu = 100
                memory = 64
            }

            template {
                change_mode = "restart"
                destination = "local/values.env"
                env = true

                data = <<EOF
{{ with secret "kv/data/letsencrypt/digitalocean" }}
DO_AUTH_TOKEN = "{{ .Data.data.token }}"{{ end }}
EOF
            }

            vault {
                policies = ["homelab"]
            }
        }

    }
}
