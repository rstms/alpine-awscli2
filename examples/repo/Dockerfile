ARG ALPINE_VERSION=3.14
FROM alpine:$ALPINE_VERSION
ARG HOST=localhost
ARG PORT=8080
RUN apk add python3 py3-pip
RUN pip install -U pip setuptools wheel
RUN pip install --trusted-host ${HOST} --index http://${HOST}:${PORT} awscli
