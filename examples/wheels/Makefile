# build with packages directory

IMAGE ?= rstms/alpine-awscli:latest

all: build run clean

# use dockerhub image to create packages directory
packages:
	docker run --rm $(IMAGE) tarball | tar zx

# build with pip install from packages directory 
build: packages
	docker build --tag wheels-example .

run:
	docker run --rm wheels-example aws --version

clean:
	rm -rf packages
	docker rmi wheels-example
