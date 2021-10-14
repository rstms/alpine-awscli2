# awscli2-alpine Makefile

DOCKER_RUN = docker run -it --rm 
DOCKER_BUILD = env DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build
MOUNT_DIST = -v $(PWD)/dist:/mnt/dist

# get the latest alpine version from the official docker container
ALPINE_VERSION ?= $(shell $(DOCKER_RUN) alpine:latest cat /etc/os-release | awk -F'[.=]' '/VERSION_ID=/{print $$2 "." $$3}')

# get the aws-cli version from the official docker container 
AWSCLI_VERSION ?= $(shell $(DOCKER_RUN) amazon/aws-cli --version | awk -F'[/ ]' '/^aws-cli/{print $$2}')

# set the python version if not in environment
PYTHON_VERSION ?= $(shell $(DOCKER_RUN) python:alpine /bin/sh -c 'python --version' | awk -F'[. ]' '/Python/{print $$2 "." $$3}' )

TAG := awscli-$(AWSCLI_VERSION)_alpine-$(ALPINE_VERSION)

.PHONY: build runtime

BUILD_ARGS = --build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
	     --build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	     --build-arg AWSCLI_VERSION=$(AWSCLI_VERSION) 


versions:
	@echo "ALPINE_VERSION=$(ALPINE_VERSION)"
	@echo "AWSCLI_VERSION=$(AWSCLI_VERSION)"
	@echo "PYTHON_VERSION=$(PYTHON_VERSION)"
	@echo "TAG=$(TAG)"

build:
	$(DOCKER_BUILD) --tag $(TAG)-build $(BUILD_ARGS) $@

runtime:
	$(DOCKER_BUILD) --tag $(TAG)-runtime $(BUILD_ARGS) $@
	
aws: runtime
	$(DOCKER_RUN) $(TAG)-runtime:latest $(CMD)

runtime-shell: runtime
	$(DOCKER_RUN) --entrypoint=/bin/sh $(TAG)-runtime:latest -l

python-alpine:
	$(DOCKER_RUN) $(MOUNT_DIST) python:$(PYTHON_VERSION)-alpine$(ALPINE_VERSION) /bin/sh -l

build-shell: build
	$(DOCKER_RUN) $(MOUNT_DIST) --entrypoint=/bin/sh $(TAG)-build:latest -l

wheels: build
	mkdir -p ./dist
	$(DOCKER_RUN) $(MOUNT_DIST) --entrypoint=/bin/sh $(TAG)-build:latest -c build_wheels
	ls -al dist

sterile: clean
	docker image prune -a

clean:
	rm -rf dist
	docker image prune -f
