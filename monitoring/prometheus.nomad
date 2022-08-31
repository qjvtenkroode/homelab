job "monitoring-prometheus" {
  datacenters = ["testing"]
  type        = "service"

  group "prometheus" {
    network {
      port "promui" {
        to = 9090
      }
    }

    service {
      check {
        name     = "prometheus status check"
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "2s"
      }

      name = "monitoring"
      port = "promui"

      tags = [
        "prometheus",
        "test-traefik.enable=true",
        "test-traefik.frontend.entryPoints=http",
        "test-traefik.http.routers.prometheus-ui-http.entrypoints=web",
        "test-traefik.http.routers.prometheus-ui-http.rule=Host(`prometheus.test-qkroode.nl`)",
        "test-traefik.http.routers.prometheus-ui-http.service=prometheus-ui",
        "test-traefik.http.services.prometheus-ui.loadbalancer.server.port=${NOMAD_HOST_PORT_promui}",
      ]
    }

    task "prometheus" {
      driver = "docker"

      artifact {
        source = "s3::http://truenas.qkroode.nl:9000/prometheus-test/prometheus.yml"
        destination = "local/"
        options {
            aws_access_key_id = "minio"
            aws_access_key_secret = "homelabminio"
            #aws_access_key_id = "${MINIO_ID}"
            #aws_access_key_secret = "${MINIO_SECRET}"
        }
      }
           # template {
           #     change_mode = "restart"
           #     destination = "local/values.env"
           #     env = true

           #     data = <<EOF
#{{ with secret "secret/minio" }}
#MINIO_ID = "{{ .Data.id }}"
#MINIO_SECRET = "{{ .Data.secret }}"
#{{ end }}
#EOF
           # }

            #vault {
            #    policies = ["homelab"]
            #}


      config {
        image = "prom/prometheus:v2.33.3"
        ports = ["promui"]

        volumes = [
          "/mnt/prometheus:/prometheus",
          "local/prometheus.yml:/etc/prometheus/prometheus.yml:z",
          "local/rules.yml:/etc/prometheus/rules.yml:z",
        ]
      }

      resources {
        cpu    = 512
        memory = 512
      }

      # TODO: move to artifacts for source
      template {
        destination = "local/rules.yml"
        data = <<-EOF
                    groups:
                    - name: PrometheusGroup
                      rules: 
                      - alert: PrometheusTargetMissing
                        expr: up == 0
                        for: 0m
                        labels:
                          severity: critical
                        annotations:
                          summary: Prometheus target missing (instance {{ "{{" }} $labels.instance {{ "}}" }})
                          description: "A Prometheus target has disappeared. An exporter might be crashed.\n  VALUE = {{ "{{" }} $value {{ "}}" }}\n  LABELS = {{ "{{" }} $labels {{ "}}" }}"
                    EOF
      }
    }
  }
}
