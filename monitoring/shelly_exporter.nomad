job "shelly-exporter" {
    datacenters = ["testing"]
    type        = "service"

    group "shelly-exporter" {
        network {
            port "shellyexportermetrics" {
                to = 8080
            }
        }

        service {
            check {
                name = "exporter status check"
                type = "http"
                path = "/metrics"
                interval = "10s"
                timeout = "2s"
            }

            name = "monitoring"
            port = "shellyexportermetrics"
            tags = [
                "exporters",
                "shelly",
                "test-traefik.enable=true",
                "test-traefik.frontend.entryPoints=http",
                "test-traefik.http.routers.exporters-shelly-http.entrypoints=web",
                "test-traefik.http.routers.exporters-shelly-http.rule=Host(`exporters.test-qkroode.nl`) && PathPrefix(`/shelly`)",
                "test-traefik.http.routers.exporters-shelly-http.middlewares=shelly-stripprefix",
                "test-traefik.http.middlewares.shelly-stripprefix.stripprefix.prefixes=/shelly",
                "test-traefik.http.routers.exporters-shelly-http.service=exporters-shelly",
                "test-traefik.http.services.exporters-shelly.loadbalancer.server.port=${NOMAD_HOST_PORT_shellyexportermetrics}"
            ]
        }

        task "shelly-exporter" {
            driver = "docker"

            config {
                image = "registry.test-qkroode.nl/homelab/prometheus-shelly-exporter:788734d"
                ports = ["shellyexportermetrics"]
            }

            resources {
                cpu = 50
                memory = 50
            }
        }
    }
}
