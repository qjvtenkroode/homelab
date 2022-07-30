# Description: private docker registry

job "registry" {
    datacenters = ["homelab"]
    type = "service"

    group "registry" {
        network {
            port "registry" {
                to = 5000
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
                "traefik.enable=true",
                "traefik.frontend.entryPoints=https",
                "traefik.http.routers.registry-https.entrypoints=web",
                "traefik.http.routers.registry-https.rule=Host(`registry.qkroode.nl`)",
                "traefik.http.routers.registry-https.service=registry",
                "traefik.http.services.registry.loadbalancer.server.port=${NOMAD_HOST_PORT_registry}"
            ]
        }
        task "registry" {
            driver = "podman"
            config {
                image = "registry:2.8.1"
                ports = ["registry"]
                volumes = ["/mnt/registry:/var/lib/registry"]
            }
            resources {
                cpu = 100
                memory = 64
            }
        }
    }
}
