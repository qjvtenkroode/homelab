job "photocatalog-database" {
  datacenters = ["homelab"]
  type        = "service"

  group "mariadb" {
    network {
      port "photoprism_database" {
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
      port = "photoprism_database"

      tags = [
        "database",
      ]
    }

    task "mariadb" {
      driver = "docker"

      config {
        image = "linuxserver/mariadb:10.5.16"
        ports = ["photoprism_database"]
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

      volume_mount {
        volume = "photoprism-db"
        destination = "/config"
        read_only = "false"
      }
    }

    volume "photoprism-db" {
      type = "host"
      read_only = false
      source = "photoprism-db"
    }
  }
}
