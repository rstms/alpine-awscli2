# syntax=docker/dockerfile:1.3-labs

ARG ALPINE_VERSION=latest
FROM alpine:$ALPINE_VERSION

ARG AWSCLI_VERSION=2.2.45

RUN \
  apk update --no-cache && \
  apk add --no-cache \
    py3-pip python3-dev groff less \
    make cmake g++ libffi-dev openssl-dev

RUN addgroup awscli && adduser -G awscli -D awscli

COPY <<EOF /bin/entrypoint
#!/bin/sh
. /home/awscli/.venv/bin/activate
exec aws \"\$@\"
EOF
RUN chmod +x /bin/entrypoint

USER awscli 
WORKDIR /home/awscli
RUN mkdir -p ./.local/bin
ENV PATH=/home/awscli/.local/bin:$PATH

RUN python3 -m venv .venv && \
  . .venv/bin/activate && \
  pip install --no-cache-dir -U pip setuptools wheel && \
  pip install --no-cache-dir -r https://raw.githubusercontent.com/aws/aws-cli/${AWSCLI_VERSION}/requirements-runtime.txt && \
  pip install --no-cache-dir --no-build-isolation https://github.com/aws/aws-cli/zipball/${AWSCLI_VERSION}#egg=awscli

ENTRYPOINT [ "/bin/entrypoint" ]
CMD [ "--version" ]
