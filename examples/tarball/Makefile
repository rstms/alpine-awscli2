# run dockerhub image to create local tarball
# run alpine base image with bind-mounted tarball
# install python and pip
# uncompress and extract tarball
# pip install awscli
# run aws

IMAGE ?= rstms/alpine-awscli:latest

all: run clean

awscli.tgz:
	docker run --rm $(IMAGE) tarball >$@

CONFIG = apk add python3 py3-pip
EXTRACT = tar xzvf /awscli.tgz
INSTALL = pip install --no-index -f packages awscli
CHECK = aws --version

CMD = '$(CONFIG) && $(EXTRACT) && $(INSTALL) && $(CHECK)'

run: awscli.tgz
	docker run --rm -v $(PWD)/awscli.tgz:/awscli.tgz alpine:latest sh -c $(CMD)

clean:
	rm awscli.tgz
