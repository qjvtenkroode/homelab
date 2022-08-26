# Description: Personal website

job "qkroode.nl" {
    datacenters = ["homelab"]
    type = "service"

    group "qkroode.nl" {
        network {
            port "http" {
                to = 80
            }
        }
        service {
            check {
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
            name = "qkroode-nl"
            port = "http"
            tags = [
                "traefik.enable=true",
                "traefik.frontend.entryPoints=http,https",
                "traefik.http.middlewares.redirect-https.redirectScheme.scheme=http",
                "traefik.http.middlewares.redirect-https.redirectScheme.permanent=true",
                "traefik.http.routers.qkroode-nl-https.rule=Host(`qkroode.nl`)",
                "traefik.http.routers.qkroode-nl-https.entrypoints=websecure",
                "traefik.http.routers.qkroode-nl-https.tls=true",
                "traefik.http.routers.qkroode-nl-https.tls.certresolver=letsencrypt",
                "traefik.http.routers.qkroode-nl-https.service=qkroode-nl",
                "traefik.http.routers.qkroode-nl-http.rule=Host(`qkroode.nl`)",
                "traefik.http.routers.qkroode-nl-http.entrypoints=web",
                "traefik.http.routers.qkroode-nl-http.middlewares=redirect-https",
                "traefik.http.routers.qkroode-nl-http.service=qkroode-nl",
                "traefik.http.services.qkroode-nl.loadbalancer.server.port=${NOMAD_HOST_PORT_http}"
            ]
        }
        task "qkroode.nl" {
            driver = "podman"

            config {
                image = "registry.service.consul:5000/homelab/qkroode.nl:0.79.0-2030477"
                ports = ["http"]
            }
            resources {
                cpu = 100
                memory = 64
            }
       }
    }
}

















