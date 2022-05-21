job "monitoring-grafana" {
  datacenters = ["testing"]
  type        = "service"

  group "grafana" {
    network {
      port "grafanaui" {
        to = 3000
      }
    }

    service {
      check {
        name     = "grafana status check"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }

      name = "monitoring"
      port = "grafanaui"

      tags = [
        "grafana",
        "test-traefik.enable=true",
        "test-traefik.frontend.entryPoints=http",
        "test-traefik.http.routers.grafana-ui-http.entrypoints=web",
        "test-traefik.http.routers.grafana-ui-http.rule=Host(`grafana.test-qkroode.nl`)",
        "test-traefik.http.routers.grafana-ui-http.service=grafana-ui",
        "test-traefik.http.services.grafana-ui.loadbalancer.server.port=${NOMAD_HOST_PORT_grafanaui}",
      ]
    }

    task "grafana" {
      driver = "podman"

      config {
        image = "grafana/grafana-oss:8.4.3"
        ports = ["grafanaui"]
      }

      resources {
        cpu    = 512
        memory = 512
      }
    }
  }
}
