# Description: All monitoring related jobs, Prometheus and AlertManager

job "monitoring-test" {
    datacenters = ["testing"]
    type = "service"

    group "prometheus" {
        network {
            port "alertmanagerui" {
                to = 9093
            }
            port "promui" {
                to = 9090
            }
        }
        service {
            check {
                name = "alertmanager status check"
                type = "http"
                path = "/-/healthy"
                interval = "10s"
                timeout = "2s"
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
                "test-traefik.http.services.alertmanager-ui.loadbalancer.server.port=${NOMAD_HOST_PORT_alertmanagerui}"
            ]
        }
        task "alertmanager" {
            driver = "podman"
            config {
                image = "prom/alertmanager:v0.23.0"
                ports = ["alertmanagerui"]
                volumes = [
#                  "local/alertmanager.yml:/etc/alertmanager/alertmanager.yml:z",
                ]
            }
            resources {
                cpu = 256
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
#                      url: http://{{ env "NOMAD_HOST_ADDR_telegram-bot" }}/alert/66750985
#              EOF
#            }
        }
        service {
            check {
                name = "prometheus status check"
                type = "http"
                path = "/-/healthy"
                interval = "10s"
                timeout = "2s"
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
                "test-traefik.http.services.prometheus-ui.loadbalancer.server.port=${NOMAD_HOST_PORT_promui}"
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
                cpu = 512
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

                    alerting:
                      alertmanagers:
                        - static_configs:
                          - targets:
                            - {{ env "NOMAD_HOST_ADDR_alertmanagerui" }}

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
                                    data = <<EOF
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
    
    group "grafana" {
        network {
            port "grafanaui" {
                to = 3000
            }
        }
        service {
            check {
                name = "grafana status check"
                type = "tcp"
                interval = "10s"
                timeout = "2s"
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
                "test-traefik.http.services.grafana-ui.loadbalancer.server.port=${NOMAD_HOST_PORT_grafanaui}"
            ]
        }
        task "grafana" {
            driver = "podman"
            config {
                image = "grafana/grafana-oss:8.4.3"
                ports = ["grafanaui"]
            }
            resources {
                cpu = 512
                memory = 512
            }
        }
    }
}
