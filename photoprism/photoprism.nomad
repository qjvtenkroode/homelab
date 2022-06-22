job "photocatalog-photoprism" {
  datacenters = ["testing"]
  type        = "service"

  group "photoprism" {
    network {
      port "photoprism" {
        to = 2342
      }
    }

    service {
      check {
        name     = "photoprism reachable check"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }

      name = "photoprism-test"
      port = "photoprism"

      tags = [
        "test-traefik.enable=true",
        "test-traefik.http.routers.photoprism-http.entrypoints=web",
        "test-traefik.http.routers.photoprism-http.rule=Host(`photoprism.test-qkroode.nl`)",
        "test-traefik.http.routers.photoprism-http.service=photoprism",
        "test-traefik.http.services.photoprism.loadbalancer.server.port=${NOMAD_HOST_PORT_photoprism}",
      ]
    }

    task "photoprism" {
      driver = "podman"

      config {
        image = "photoprism/photoprism:latest"
        ports = ["photoprism"]

        volumes = [
          "/mnt/originals:/photoprism/originals",
          "/mnt/photoprism:/photoprism/storage",
        ]
      }

      env {
        PHOTOPRISM_UPLOAD_NSFW       = true
        PHOTOPRISM_ADMIN_PASSWORD    = "insecure"
        PHOTOPRISM_READONLY          = false
        PHOTOPRISM_WORKERS           = 2
        PHOTOPRISM_DATABASE_DRIVER   = "mysql"
        PHOTOPRISM_DATABASE_SERVER   = "database.photoprism.service.consul:3306"
        PHOTOPRISM_DATABASE_NAME     = "photoprism"
        PHOTOPRISM_DATABASE_USER     = "photoprism"
        PHOTOPRISM_DATABASE_PASSWORD = "insecure"
      }

      resources {
        cpu    = 2048
        memory = 2048
      }
    }
  }
}
