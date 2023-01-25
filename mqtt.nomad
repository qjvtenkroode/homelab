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
                "urlprefix-mqtt.qkroode.nl:1883 proto=tcp",
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
            resources {
                cpu = 100
                memory = 100
            }
        }
    }
    type = "service"
}
