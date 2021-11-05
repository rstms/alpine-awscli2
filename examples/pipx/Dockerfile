ARG ALPINE_VERSION=3.14
FROM alpine:$ALPINE_VERSION
ARG HOST=localhost
ARG PORT=8080
ENV PATH=/root/.local/bin:${PATH}
RUN apk add python3 py3-pip
RUN pip install -U pip setuptools wheel pipx
RUN pipx install --pip-args "--trusted-host ${HOST} --index http://${HOST}:${PORT}" awscli
