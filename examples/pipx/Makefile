# run dockerhub image as local pypi-compatible repo
# docker build using pip to install awscli from repo

IMAGE ?= rstms/alpine-awscli:latest
HOST := $(shell hostname -f)
PORT := 8888

all: start build run stop clean

start:
	docker run --rm --detach --name pipx-example --publish $(PORT):8080 $(IMAGE)

stop:
	docker rm -f pipx-example || true

build:
	docker build --build-arg HOST=$(HOST) --build-arg PORT=$(PORT) --tag pipx-example .

run:
	docker run --rm pipx-example:latest /bin/sh -c 'aws --version'

clean: stop
	docker rmi -f pipx-example || true
