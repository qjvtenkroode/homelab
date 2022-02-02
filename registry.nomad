# Description: private docker registry

job "registry-test" {
    datacenters = ["testing"]
    type = "service"

    group "registry" {
        network {
            port "registry" {}
        }
        service  {
            port = "registry"
            check {
                name = "registry reachable check"
                type = "tcp"
                interval = "10s"
                timeout = "2s"
            }
        }
        task "registry" {
            driver = "podman"
            config {
                image = "registry:latest"
            }
            resources {
                cpu = 100
                memory = 64
            }
        }
    }
}
