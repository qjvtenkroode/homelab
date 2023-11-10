# Description: Personal website

job "qkroode.nl" {
    datacenters = ["homelab"]
    type = "service"

    group "qkroode.nl" {
        network {
            port "http" {
                to = 80
            }
        }
        service {
            check {
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
            name = "qkroode-nl"
            port = "http"
            tags = [
                "urlprefix-qkroode.nl/"
            ]
        }
        task "qkroode.nl" {
            driver = "docker"

            config {
                image = "registry.service.consul:5000/homelab/qkroode.nl:0.79.0-2030477"
                ports = ["http"]
            }
            resources {
                cpu = 100
                memory = 64
            }
       }
    }
}

















