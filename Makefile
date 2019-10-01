
TAG := $(shell git rev-parse --verify --short HEAD)

builddocs:
	@eval $$(aws ecr get-login --no-include-email)
	docker build -t 531831122766.dkr.ecr.us-west-2.amazonaws.com/docs:$(TAG) -f build/Dockerfile .
	docker push 531831122766.dkr.ecr.us-west-2.amazonaws.com/docs:$(TAG)
