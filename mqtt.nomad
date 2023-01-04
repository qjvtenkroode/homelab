# Description: mosquitto for MQTT

job "mosquitto" {
    datacenters = ["homelab"]
    group "mosquitto" {
        network {
            port "mqtt" {
                to = 1883
            }
        }
        service {
            check {
                interval = "10s"
                timeout = "2s"
                type = "tcp"
            }
            name = "mosquitto"
            port = "mqtt"
            tags = [
                "urlprefix-/",
            ]
        }
        task "mosquitto" {
            config {
                image = "eclipse-mosquitto:1.6"
                network_mode = "bridge"
                ports = ["mqtt"]
                privileged = false
            }
            driver = "docker"
            env {}
            resources {
                cpu = 100
                memory = 100
            }
        }
    }
    type = "service"
}
