job "monitoring-prometheus" {
  datacenters = ["testing"]
  type        = "service"

  group "prometheus" {
    network {
      port "promui" {
        to = 9090
      }
    }

    service {
      check {
        name     = "prometheus status check"
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "2s"
      }

      name = "monitoring"
      port = "promui"

      tags = [
        "prometheus",
        "test-traefik.enable=true",
        "test-traefik.frontend.entryPoints=http",
        "test-traefik.http.routers.prometheus-ui-http.entrypoints=web",
        "test-traefik.http.routers.prometheus-ui-http.rule=Host(`prometheus.test-qkroode.nl`)",
        "test-traefik.http.routers.prometheus-ui-http.service=prometheus-ui",
        "test-traefik.http.services.prometheus-ui.loadbalancer.server.port=${NOMAD_HOST_PORT_promui}",
      ]
    }

    task "prometheus" {
      driver = "podman"

      config {
        image = "prom/prometheus:v2.33.3"
        ports = ["promui"]

        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml:z",
          "local/rules.yml:/etc/prometheus/rules.yml:z",
        ]
      }

      resources {
        cpu    = 512
        memory = 512
      }

      template {
        destination = "local/prometheus.yml"

        data = <<-EOF
                    global:
                      scrape_interval:     15s
                      evaluation_interval: 15s

                    rule_files:
                      - 'rules.yml'

                    #alerting:
                    #  alertmanagers:
                    #    - static_configs:
                    #      - targets:
                    #      # TODO enable and change to using a Traefik endpoint
                    #        - {{ env "NOMAD_HOST_ADDR_alertmanagerui" }}

                    scrape_configs:
                      - job_name: prometheus
                        static_configs:
                          - targets: ['localhost:9090']
                      - job_name: solaredge
                        scrape_interval: 5s
                        static_configs:
                          - targets: ['stargazer.qkroode.nl:2112']
                      - job_name: node-exporter
                        consul_sd_configs:
                          - server: consul.service.consul:8500
                            services: [node_exporter]
                      - job_name: consul
                        metrics_path: 'v1/agent/metrics'
                        params:
                          format: ["prometheus"]
                        static_configs:
                          - targets: ['dominion.qkroode.nl:8500']
                      - job_name: traefik
                        consul_sd_configs:
                          - server: consul.service.consul:8500
                            services: [traefik-test]
                                    EOF
      }

      template {
        destination = "local/rules.yml"

        data = <<-EOF
                    groups:
                    - name: PrometheusGroup
                      rules: 
                      - alert: PrometheusTargetMissing
                        expr: up == 0
                        for: 0m
                        labels:
                          severity: critical
                        annotations:
                          summary: Prometheus target missing (instance {{ "{{" }} $labels.instance {{ "}}" }})
                          description: "A Prometheus target has disappeared. An exporter might be crashed.\n  VALUE = {{ "{{" }} $value {{ "}}" }}\n  LABELS = {{ "{{" }} $labels {{ "}}" }}"
                    EOF
      }
    }
  }
}
