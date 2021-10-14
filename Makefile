# awscli2-alpine Makefile

DOCKER_RUN = docker run -it --rm 
DOCKER_BUILD = env DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build
MOUNT_DIST = -v $(PWD)/dist:/mnt/dist

# get the latest alpine version from the official docker container
ALPINE_VERSION ?= $(shell $(DOCKER_RUN) alpine:latest cat /etc/os-release | awk -F= '/VERSION_ID=/{print $$2}')

# get the aws-cli version from the official docker container 
AWSCLI_VERSION ?= $(shell $(DOCKER_RUN) amazon/aws-cli --version | awk -F'[/ ]' '/^aws-cli/{print $$2}')

TAG := awscli-$(AWSCLI_VERSION)_alpine-$(ALPINE_VERSION)

.PHONY: build runtime

versions:
	@echo "ALPINE_VERSION=$(ALPINE_VERSION)"
	@echo "AWSCLI_VERSION=$(AWSCLI_VERSION)"
	@echo "TAG=$(TAG)"

build:
	$(DOCKER_BUILD) \
	  --tag $(TAG)-build \
	  --build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
	  --build-arg AWSCLI_VERSION=$(AWSCLI_VERSION) \
	  $@

runtime:
	$(DOCKER_BUILD) \
	  --tag $(TAG)-runtime \
	  --build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
	  --build-arg AWSCLI_VERSION=$(AWSCLI_VERSION) \
	  $@
	
aws: runtime
	$(DOCKER_RUN) $(TAG)-runtime:latest $(CMD)

runtime-shell: runtime
	$(DOCKER_RUN) --entrypoint=/bin/sh $(TAG)-runtime:latest -l

alpine:
	$(DOCKER_RUN) alpine:latest $(CMD)

build-shell: build
	$(DOCKER_RUN) $(MOUNT_DIST) --entrypoint=/bin/sh $(TAG)-build:latest -l

wheels: build
	mkdir -p ./dist
	$(DOCKER_RUN) $(MOUNT_DIST) --entrypoint=/bin/sh $(TAG)-build:latest -c "spin-wheels"
	ls -al dist

sterile: clean
	docker image prune -a

clean:
	rm -rf dist
	docker image prune -f
