# awscli2-alpine Makefile

DOCKER_RUN = docker run -it --rm 

# get the latest alpine version from the official docker container
ALPINE_VERSION ?= $(shell $(DOCKER_RUN) alpine:latest cat /etc/os-release | awk -F= '/VERSION_ID=/{print $$2}')

# get the aws-cli version from the official docker container 
AWSCLI_VERSION ?= $(shell docker run --rm -it amazon/aws-cli --version | awk -F'[/ ]' '/^aws-cli/{print $$2}')

TAG := awscli-$(AWSCLI_VERSION)_alpine-$(ALPINE_VERSION)

versions:
	@echo "ALPINE_VERSION=$(ALPINE_VERSION)"
	@echo "AWSCLI_VERSION=$(AWSCLI_VERSION)"
	@echo "TAG=$(TAG)"

build: Dockerfile 
	docker build \
	  --tag $(TAG) \
	  --build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
	  --build-arg AWSCLI_VERSION=$(AWSCLI_VERSION) \
	  - <$<

run:
	docker run -it --rm $(TAG):latest $(CMD)

shell:
	docker run -it --rm $(TAG):latest /bin/bash

wheel: build
	docker run -v $(PWD):/mnt/dist -it --rm $(TAG):latest "cp aws-cli/dist/*.whl /mnt/dist"	
	@ls *.whl

dockerclean:
	docker image prune -a

clean:
	rm -f *.whl
	docker image prune -y

