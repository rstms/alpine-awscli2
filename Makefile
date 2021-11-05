# awscli2-alpine Makefile

ORG:=rstms

# DOCKER_RUN(args,image_name)
DOCKER_RUN = $(ENV) docker run --rm $(1) $(2)

# DOCKER_BUILD(args,image_name)
DOCKER_BUILD = $(ENV) docker build $(1) --tag $(2):latest $(2)

BUILD_ENV = DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain

# get the latest alpine version from the official docker container
ALPINE_VERSION ?= $(shell $(call DOCKER_RUN,alpine:latest,) cat /etc/os-release | awk -F'[.=]' '/VERSION_ID=/{print $$2 "." $$3}')

# get the aws-cli version from the official docker container 
AWSCLI_VERSION ?= $(shell $(call DOCKER_RUN,,amazon/aws-cli:latest) --version | awk -F'[/ ]' '/^aws-cli/{print $$2}')

# set the python version if not in environment
PYTHON_VERSION ?= $(shell python --version | awk -F'[. ]' '/Python/{print $$2 "." $$3}' )

# set the host systems docker group ID
DOCKER_GID := $(shell awk </etc/group -F: '/docker/{print $$3}')

IMAGE := alpine-awscli
TAG := awscli-$(AWSCLI_VERSION)_alpine-$(ALPINE_VERSION)

.PHONY: build wheels

# set environment vars for docker commands
ENV := env\
 DOCKER_BUILDKIT=1\
 BUILDKIT_PROGRESS=plain\
 ALPINE_VERSION=$(ALPINE_VERSION)\
 PYTHON_VERSION=$(PYTHON_VERSION)\
 AWSCLI_VERSION=$(AWSCLI_VERSION) \
 DOCKER_GID=$(DOCKER_GID)

exports:
	@$(foreach VAR,ALPINE PYTHON AWSCLI,echo export $(VAR)_VERSION=$($(VAR)_VERSION);)

build:
	$(call DOCKER_BUILD,,build) 

rebuild:
	$(call DOCKER_BUILD,--no-cache,build) 

# tag_and_push(local_image,org,name,version)
tag_and_push = docker tag $(1) $(2)/$(3):$(4) && docker push $(2)/$(3):$(4)
  
publish:
	@echo pushing images to dockerhub
	$(if $(wildcard ~/.docker/config.json),docker login,$(error docker-publish failed; ~/.docker/config.json required))
	$(foreach DOCKERTAG,$(TAG) latest,$(call tag_and_push,build:latest,$(ORG),$(IMAGE),$(DOCKERTAG));)

run:
	$(call DOCKER_RUN,--publish 8080:8080,build:latest)



TEST_CMD := 'eval $$(docker run rstms/alpine-awscli:latest install) && aws --version'
TEST_BUILD := $(call DOCKER_BUILD,--build-arg DOCKER_GID=$(DOCKER_GID),test)
TEST_RUN := $(call DOCKER_RUN,-v /var/run/docker.sock:/var/run/docker.sock,test:latest) /bin/sh -c $(TEST_CMD)

test:
	cd examples && make IMAGE=build:latest all

tarball:
	$(call DOCKER_RUN,,build:latest) tarball >awscli-wheels.tgz

wheels: 
	rm -rf packages wheels
	$(call DOCKER_RUN,,build:latest) tarball | tar zx 
	mv packages wheels
	ls -al wheels 

sterile: clean
	docker image prune -a -f

clean:
	docker image prune -f
	rm -f .dockerhub
	rm -f awscli-wheels.tgz
	rm -rf packages wheels
