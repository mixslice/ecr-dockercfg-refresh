
IMAGE=ecr-dockercfg-refresh
TAG=0.1

.PHONY: build push

build:
	docker build -t mixslice/$(IMAGE):$(TAG) .

push:
	docker push mixslice/$(IMAGE):$(TAG)
