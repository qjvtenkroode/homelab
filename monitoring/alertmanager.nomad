job "monitoring-alertmanager" {
  datacenters = ["testing"]
  type        = "service"

  group "alertmanager" {
    network {
      port "alertmanagerui" {
        to = 9093
      }
    }

    service {
      check {
        name     = "alertmanager status check"
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "2s"
      }

      name = "monitoring"
      port = "alertmanagerui"

      tags = [
        "alertmanager",
        "test-traefik.enable=true",
        "test-traefik.frontend.entryPoints=http",
        "test-traefik.http.routers.alertmanager-ui-http.entrypoints=web",
        "test-traefik.http.routers.alertmanager-ui-http.rule=Host(`alertmanager.test-qkroode.nl`)",
        "test-traefik.http.routers.alertmanager-ui-http.service=alertmanager-ui",
        "test-traefik.http.services.alertmanager-ui.loadbalancer.server.port=${NOMAD_HOST_PORT_alertmanagerui}",
      ]
    }

    task "alertmanager" {
      driver = "docker"

      config {
        image   = "prom/alertmanager:v0.23.0"
        ports   = ["alertmanagerui"]
        volumes = []

      #                  "local/alertmanager.yml:/etc/alertmanager/alertmanager.yml:z",
      }

      resources {
        cpu    = 256
        memory = 256
      }

      #            template {
      #              destination = "local/alertmanager.yml"
      #              data = <<-EOF
      #                global:
      #                  resolve_timeout: 5m
      #                route:
      #                  group_by : ['alertname']
      #                  group_wait: 30s
      #                  group_interval: 30s
      #                  repeat_interval: 5m
      #                  receiver: 'telegram'
      #                receivers:
      #                  - name: 'telegram'
      #                    webhook_configs:
      #                    - send_resolved: True
      #                      # TODO enable and change to use consul or traefik
      #                      url: http://{{ env "NOMAD_HOST_ADDR_telegram-bot" }}/alert/66750985
      #              EOF
      #            }
    }
  }
}
