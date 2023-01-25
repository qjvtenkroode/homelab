# Description: Fabio as frontend proxy for all exposed services within Nomad cluster
#              since Traefik will not store certificates in a store such as Vault

job "fabio" {
    datacenters = ["homelab"]
    type = "system"

    group "fabio" {
        network {
            port "metrics" {
                static = 8000
                to = 8000
            }
            port "mqtt" {
                static = 1883
                to = 1883 
            }
            port "ui" {
                static = 9998
                to = 9998
            }
            port "http" {
                static = 9999
                to = 9999
            }
        }
        service  {
            check {
                name = "fabio reachable check"
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
            name = "fabio"
            port = "ui"
            tags = []
        }
        task "fabio" {
            driver = "docker"
            config {
                image = "docker.io/fabiolb/fabio:latest"
                ports = ["metrics","ui","http", "mqtt"]
                args = []
                network_mode = "host"
                volumes = ["local/fabio.properties:/etc/fabio/fabio.properties:z"]
            }
            resources {
                cpu = 100
                memory = 64
            }
            template {
                destination = "local/fabio.properties"
                data = <<-EOF
                    metrics.target = prometheus
                    metrics.prefix = {{`{{clean .Exec}}`}}
                    proxy.cs = cs=mycerts;type=consul;cert=http://localhost:8500/v1/kv/fabio/cert
                    proxy.addr = :1883;proto=tcp,:9999;cs=mycerts,:8000;proto=prometheus
                EOF
            }
        }
    }
}
