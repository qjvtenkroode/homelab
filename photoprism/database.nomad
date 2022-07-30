job "photocatalog-database" {
  datacenters = ["homelab"]
  type        = "service"

  group "mariadb" {
    network {
      port "photoprism-database" {
        static = 3306
        to     = 3306
      }
    }

    service {
      check {
        name     = "photoprism database reachable check"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }

      name = "photoprism"
      port = "photoprism-database"

      tags = [
        "database",
      ]
    }

    task "mariadb" {
      driver = "podman"

      config {
        image = "linuxserver/mariadb:10.5.16"
        ports = ["photoprism-database"]

        volumes = [
          "/mnt/photoprism/database:/config",
        ]
      }

      env {
        MYSQL_ROOT_PASSWORD      = "insecure"
        MYSQL_DATABASE           = "photoprism"
        MYSQL_USER               = "photoprism"
        MYSQL_PASSWORD           = "insecure"
        MYSQL_INITDB_SKIP_TZINFO = "1"
      }

      resources {
        cpu    = 512
        memory = 512
      }
    }
  }
}
