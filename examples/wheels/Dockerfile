ARG ALPINE_VERSION=3.14
FROM alpine:$ALPINE_VERSION
RUN apk add python3 py3-pip
RUN pip install -U pip setuptools wheel

COPY ./packages ./packages
RUN pip install --no-index --find-links ./packages awscli
