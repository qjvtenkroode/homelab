job "photocatalog-photoprism" {
  datacenters = ["homelab"]
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

      name = "photoprism"
      port = "photoprism"

      tags = [
        "urlprefix-photoprism.qkroode.nl/"
      ]
    }

    task "photoprism" {
      driver = "docker"

      config {
        image = "photoprism/photoprism:220617-bookworm"
        ports = ["photoprism"]
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
      
      volume_mount {
        volume = "photoprism-app"
        destination = "/photoprism/storage"
        read_only = "false"
      }
      volume_mount {
        volume = "photoprism-originals"
        destination = "/photoprism/originals"
        read_only = "false"
      }
    }
    volume "photoprism-app" {
      type = "host"
      read_only = false
      source = "photoprism-app"
    }
    volume "photoprism-originals" {
      type = "host"
      read_only = false
      source = "photoprism-originals"
    }
  }
}
