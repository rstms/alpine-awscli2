# Makefile for builder

AWSCLI_VERSION ?= 2.2.45

MUSL_LIBC_VERSION := $(shell ldd 2>&1 | awk -F'[ .]' '/Version/{print $$2 "_" $$3}')
PLATFORM_TAG := musllinux_$(MUSL_LIBC_VERSION)_$(shell uname -m)

GIT_PKGS := git
BUILD_PKGS := make cmake g++ libffi-dev openssl-dev 

PKG_ADD = sudo apk add --no-cache --virtual .$(1)_PKGS $($(1)_PKGS)
PKG_DEL = sudo apk del --no-network .$(1)_PKGS

VENV := . .venv/bin/activate && cd aws-cli &&

BUILDS := build check runtime test

WHEEL_DIRS := $(foreach BUILD,$(BUILDS),-f dist/$(BUILD) )

clone:
	$(call PKG_ADD,GIT)
	git clone https://github.com/aws/aws-cli --branch v2
	cd aws-cli && git checkout -b $(AWSCLI_VERSION)
	$(call PKG_DEL,GIT)

# test for pinned botocore egg in requirements-runtime.txt (break docker build if/when this changes)
repo-test:
	grep -q 'https://github.com/boto/botocore/zipball/v2#egg=botocore' aws-cli/requirements-runtime.txt 

virtualenv:
	python3 -m venv .venv

pip-update:
	$(VENV) pip install --no-cache-dir --upgrade pip setuptools wheel

build:
	$(call PKG_ADD,BUILD)
	$(foreach BUILD,$(BUILDS),mkdir -p dist/$(BUILD);)
	$(VENV) $(foreach BUILD,$(BUILDS),pip wheel -w dist/$(BUILD) -r requirements-$(BUILD).txt;)
	$(VENV) pip wheel -w dist --no-cache-dir $(WHEEL_DIRS) .
	$(call PKG_DEL,BUILD)

install:
	$(VENV) pip install --no-cache-dir $(WHEEL_DIRS) dist/*.whl

pip-purge:
	$(VENV) pip cache purge
