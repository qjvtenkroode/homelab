.PHONY: help cribl prometheus-shelly-exporter-test qkroode.nl qkroode.nl-test

help:
	@echo ""
	@echo "usage:"
	@echo ""
	@echo "all - build all Dockerfiles and push them to remote private repo"
	@echo "all-test - build all Dockerfiles and push them to remote private test-repo"
	@echo "cribl - build cribl Dockerfile and push to remote private repo"
	@echo "prometheus-shelly-exporter-test - build prometheus-shelly-exporter Dockerfile and push to remote private test-repo"
	@echo "qkroode.nl - build qkroode.nl hugo Dockerfile and push to remote private repo"
	@echo "qkroode.nl-test - build qkroode.nl hugo Dockerfile and push to remote private test-repo"
	@echo ""

all: cribl qkroode.nl

all-test: prometheus-shelly-exporter-test qkroode.nl-test

cribl:
	$(eval ENV-CRIBL := $(shell grep 'ENV VERSION=' cribl/Dockerfile | cut -d = -f 2))
	$(eval ENV-CRIBL-conf := $(shell git --git-dir ../cribl/.git log --pretty=format:"%h" -1))
	docker build --no-cache -t registry.service.consul:5000/homelab/cribl:$(ENV-CRIBL)-$(ENV-CRIBL-conf) ./cribl
	docker image push registry.service.consul:5000/homelab/cribl:$(ENV-CRIBL)-$(ENV-CRIBL-conf)

prometheus-shelly-exporter-test:
	$(eval ENV-prometheus-shelly-exporter := $(shell git --git-dir ../homelab-prometheus-shelly-exporter/.git log --pretty=format:"%h" -1))
	docker build --no-cache -t registry.test-qkroode.nl/homelab/prometheus-shelly-exporter:$(ENV-prometheus-shelly-exporter) ./prometheus-shelly-exporter
	docker image push registry.test-qkroode.nl/homelab/prometheus-shelly-exporter:$(ENV-prometheus-shelly-exporter)


qkroode.nl:
	$(eval ENV-HUGO := $(shell grep 'ENV VERSION=' qkroode.nl/Dockerfile | cut -d = -f 2))
	$(eval ENV-qkroode := $(shell git --git-dir ../../qkroode.nl/.git log --pretty=format:"%h" -1))
	docker build --no-cache -t registry.service.consul:5000/homelab/qkroode.nl:$(ENV-HUGO)-$(ENV-qkroode) ./qkroode.nl
	docker image push registry.service.consul:5000/homelab/qkroode.nl:$(ENV-HUGO)-$(ENV-qkroode)

qkroode.nl-test:
	$(eval ENV-HUGO := $(shell grep 'ENV VERSION=' qkroode.nl/Dockerfile | cut -d = -f 2))
	$(eval ENV-qkroode := $(shell git --git-dir ../../qkroode.nl/.git log --pretty=format:"%h" -1))
	docker build --no-cache -t registry.test-qkroode.nl/homelab/qkroode.nl:$(ENV-HUGO)-$(ENV-qkroode) ./qkroode.nl
	docker image push registry.test-qkroode.nl/homelab/qkroode.nl:$(ENV-HUGO)-$(ENV-qkroode)
