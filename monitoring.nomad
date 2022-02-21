# Description: All monitoring related jobs, Prometheus and AlertManager

job "monitoring-test" {
    datacenters = ["testing"]
    type = "service"

    group "monitoring" {
        network {
            port "prom-ui" {
                to = 9090
            }
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
            port = "prom-ui"
            tags = ["prometheus"]
        }
        task "prometheus" {
            driver = "podman"
            config {
                image = "prom/prometheus:v2.33.3"
                ports = ["prom-ui"]
                volumes = [
                  "local/prometheus.yml:/etc/prometheus/prometheus.yml:z",
                ]
            }
            resources {
                cpu = 1024
                memory = 2048
            }
            template {
                destination = "local/prometheus.yml"
                data = <<EOF
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
  - job_name: node-exporter
    consul_sd_configs:
      - server: consul.service.consul:8500
        services: [node_exporter]
  - job_name: traefik
    consul_sd_configs:
      - server: consul.service.consul:8500
        services: [traefik, traefik-test]
                EOF
            }
        }
    }
}
