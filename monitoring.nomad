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
                name = "prometheus ui reachability check"
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
            port = "prom-ui"
        }
        task "prometheus" {
            driver = "podman"
            config {
                image = "prom/prometheus:v2.33.3"
                ports = "prom-ui"
            }
            resources {
                cpu = 1024
                memory = 2048
            }
        }
    }
}
