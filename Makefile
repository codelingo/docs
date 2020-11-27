TAG := $(shell git rev-parse --verify --short HEAD)
REGISTRY = codelingo.azurecr.io

buildimage:
	docker build -t $(REGISTRY)/docs:$(TAG) -f build/Dockerfile .
	docker push $(REGISTRY)/docs:$(TAG)
