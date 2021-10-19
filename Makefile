# awscli2-alpine Makefile

DOCKER_RUN = docker run -it --rm 
DOCKER_BUILD = env DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build
MOUNT_DIST = -v $(PWD)/dist:/mnt/dist
MOUNT_SCRIPTS = -v $(PWD)/scripts:/mnt/scripts

CREATE_DIST := $(shell [ -e dist ] || mkdir dist)

# get the latest alpine version from the official docker container
ALPINE_VERSION ?= $(shell $(DOCKER_RUN) alpine:latest cat /etc/os-release | awk -F'[.=]' '/VERSION_ID=/{print $$2 "." $$3}')

# get the aws-cli version from the official docker container 
AWSCLI_VERSION ?= $(shell $(DOCKER_RUN) amazon/aws-cli --version | awk -F'[/ ]' '/^aws-cli/{print $$2}')

# set the python version if not in environment
PYTHON_VERSION ?= $(shell python --version | awk -F'[. ]' '/Python/{print $$2 "." $$3}' )

TAG := awscli-$(AWSCLI_VERSION)_alpine-$(ALPINE_VERSION)

.PHONY: build runtime test

BUILD_ARGS = --build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
	     --build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	     --build-arg AWSCLI_VERSION=$(AWSCLI_VERSION) 


exports:
	@echo "export ALPINE_VERSION=$(ALPINE_VERSION)"
	@echo "export AWSCLI_VERSION=$(AWSCLI_VERSION)"
	@echo "export PYTHON_VERSION=$(PYTHON_VERSION)"

build:
	$(DOCKER_BUILD) --tag $(TAG)-build $(BUILD_ARGS) $@

build-shell: build
	$(DOCKER_RUN) $(MOUNT_DIST) --entrypoint=/bin/sh $(TAG)-build:latest -l

devpi:
	$(DOCKER_RUN) $(MOUNT_DIST) --expose 3141 $(TAG)-build:latest devpi


runtime:
	$(DOCKER_BUILD) --tag $(TAG)-runtime $(BUILD_ARGS) $@

runtime-shell: runtime
	$(DOCKER_RUN) --entrypoint=/bin/sh $(TAG)-runtime:latest -l

test:
	$(DOCKER_BUILD) --tag $(TAG)-test $(BUILD_ARGS) $@

test-shell:
	$(DOCKER_RUN) $(MOUNT_DIST) $(MOUNT_SCRIPTS) $(TAG)-test:latest $(CMD)


aws: runtime
	$(DOCKER_RUN) $(TAG)-runtime:latest $(CMD)

python-alpine:
	$(DOCKER_RUN) $(MOUNT_DIST) $(MOUNT_SCRIPTS) python:$(PYTHON_VERSION)-alpine$(ALPINE_VERSION) /bin/sh -l

wheels: 
	mkdir -p ./dist
	$(DOCKER_RUN) $(MOUNT_DIST) --entrypoint=/bin/sh $(TAG)-build:latest -c "cp aws-cli/dist/*.whl /mnt/dist"
	ls -al dist

sterile: clean
	docker image prune -a

clean:
	rm -rf dist
	docker image prune -f
