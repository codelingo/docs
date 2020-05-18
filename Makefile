
TAG := $(shell git rev-parse --verify --short HEAD)
PROD_REGISTRY := us.gcr.io/codelingo-production-276401
STAGING_REGISTRY := us.gcr.io/codelingo-staging-276400
DEV_REGISTRY = localhost:5000

builddev:
	docker build -t $(DEV_REGISTRY)/docs:$(TAG) -f build/Dockerfile .
	docker push $(DEV_REGISTRY)/docs:$(TAG)

buildstaging:
	docker build -t $(STAGING_REGISTRY)/docs:$(TAG) -f build/Dockerfile .
	docker push $(STAGING_REGISTRY)/docs:$(TAG)

buildprod:
	docker build -t $(PROD_REGISTRY)/docs:$(TAG) -f build/Dockerfile .
	docker push $(PROD_REGISTRY)/docs:$(TAG)
