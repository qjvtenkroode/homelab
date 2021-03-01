.PHONY: help cribl qkroode.nl

help:
	@echo ""
	@echo "usage:"
	@echo ""
	@echo "all - build all Dockerfiles and push them to remote private repo"
	@echo "cribl - build cribl Dockerfile and push to remote private repo"
	@echo "qkroode.nl - build qkroode.nl hugo Dockerfile and push to remote private repo"
	@echo ""

all: cribl qkroode.nl

cribl:
	$(eval ENV-CRIBL := $(shell grep 'ENV VERSION=' cribl/Dockerfile | cut -d = -f 2))
	$(eval ENV-CRIBL-conf := $(shell git --git-dir ../cribl/.git log --pretty=format:"%h" -1))
	docker build --no-cache -t registry.service.consul:5000/homelab/cribl:$(ENV-CRIBL)-$(ENV-CRIBL-conf) ./cribl
	docker image push registry.service.consul:5000/homelab/cribl:$(ENV-CRIBL)-$(ENV-CRIBL-conf)

qkroode.nl:
	$(eval ENV-HUGO := $(shell grep 'ENV VERSION=' qkroode.nl/Dockerfile | cut -d = -f 2))
	$(eval ENV-qkroode := $(shell git --git-dir ../../qkroode.nl/.git log --pretty=format:"%h" -1))
	docker build --no-cache -t registry.service.consul:5000/homelab/qkroode.nl:$(ENV-HUGO)-$(ENV-qkroode) ./qkroode.nl
	docker image push registry.service.consul:5000/homelab/qkroode.nl:$(ENV-HUGO)-$(ENV-qkroode)
