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
          "/mnt/prometheus:/prometheus",
          "local/prometheus.yml:/etc/prometheus/prometheus.yml:z",
          "local/rules.yml:/etc/prometheus/rules.yml:z",
        ]
      }

      resources {
        cpu    = 512
        memory = 512
      }

      # TODO: move to artifacts for source
      template {
        destination = "local/prometheus.yml"
        data = <<-EOF
                    global:
                      scrape_interval:     15s
                      evaluation_interval: 15s

                    rule_files:
                      - 'rules.yml'

                    alerting:
                      alertmanagers:
                        - static_configs:
                          - targets:
                            - alertmanager.test-qkroode.nl

                    scrape_configs:
                      # default prometheus data
                      - job_name: prometheus
                        static_configs:
                          - targets: ['localhost:9090']
                      # default nomad data
                      - job_name: nomad
                        metrics_path: /v1/metrics
                        scrape_interval: 5s
                        params:
                          format: ["prometheus"]
                        consul_sd_configs:
                          - server: consul.service.consul:8500
                            services: ['nomad-client', 'nomad']
                        relabel_configs:
                          - source_labels: ['__meta_consul_tags']
                            regex: '(.*)http(.*)'
                            action: keep
                      # default consul data
                      - job_name: consul
                        metrics_path: 'v1/agent/metrics'
                        params:
                          format: ["prometheus"]
                        static_configs:
                          - targets: ['dominion.qkroode.nl:8500']
                      # node_exporter data
                      - job_name: node_exporter
                        consul_sd_configs:
                          - server: consul.service.consul:8500
                            services: [node_exporter]
                      # exporters
                      - job_name: exporters
                        consul_sd_configs:
                          - server: consul.service.consul:8500
                            services: [monitoring]
                            tags: [exporters]
                        relabel_configs:
                        # expects tags for exports to be "exporters, <type_name>, ..."
                          - source_labels: ['__meta_consul_tags']
                            regex: '(.*)exporters\,([^\,]+)(.*)'
                            target_label: type
                            replacement: $2
                      # default traefik data
                      - job_name: traefik
                        consul_sd_configs:
                          - server: consul.service.consul:8500
                            services: [traefik-test]
                      - job_name: shellies
                        static_configs:
                          - targets:
                            - shelly1pm-b1e281.qkroode.nl
                            - shelly1pm-6090fc.qkroode.nl
                            - shellydimmer2-e0980695af1a.qkroode.nl
                            - shellydimmer2-e0980695add5.qkroode.nl
                        metrics_path: /shelly/probe
                        relabel_configs:
                          - source_labels: [__address__]
                            target_label: __param_target
                          - source_labels: [__param_target]
                            target_label: instance
                          - target_label: __address__
                            replacement: exporters.test-qkroode.nl
#                      # solaredge inverter data through modbus exporter
#                      - job_name: solaredge
#                        scrape_interval: 5s
#                        static_configs:
#                          - targets: ['stargazer.qkroode.nl:2112']
                                    EOF
      }

      # TODO: move to artifacts for source
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
