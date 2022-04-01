# Description: private docker registry

job "test-registry" {
    datacenters = ["testing"]
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
            name = "registry-test"
            port = "registry"
            tags = [
                "test-traefik.enable=true",
                "test-traefik.frontend.entryPoints=https",
                "test-traefik.http.routers.registry-https.entrypoints=web",
                "test-traefik.http.routers.registry-https.rule=Host(`registry.test-qkroode.nl`)",
                "test-traefik.http.routers.registry-https.service=registry",
                "test-traefik.http.services.registry.loadbalancer.server.port=${NOMAD_HOST_PORT_registry}"
            ]
        }
        task "registry" {
            driver = "podman"
            config {
                image = "registry:latest"
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
