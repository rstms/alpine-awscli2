# alpine-awscli2 build

ARG ALPINE_VERSION=3.14
FROM alpine:$ALPINE_VERSION as builder 

ARG AWSCLI_VERSION=2.0.35

RUN \
  apk update && \
  apk add --no-cache \
    bash \
    cmake \
    g++ \
    git \
    groff \
    less \
    make \
    libffi-dev \
    openssl-dev \
    python3-dev \
    py3-pip

ENV USER=builder

RUN \
  addgroup ${USER} && \
  adduser -G ${USER} -D ${USER} && \
  mkdir -p /home/${USER}/.local/bin && \
  chown -R ${USER}.${USER} /home/${USER} 

ENV PATH=/home/${USER}/.local/bin:${PATH}

USER ${USER}
WORKDIR /home/${USER}

RUN pip install --no-cache-dir --upgrade pip setuptools wheel==0.37.0

RUN \
  mkdir dist && \
  git clone https://github.com/aws/aws-cli --branch v2 && \
  cd aws-cli && \
  git checkout -b ${AWSCLI_VERSION} && \
  mkdir dist-requirements && \
  pip wheel -w dist-requirements \
    -r requirements-build.txt \
    -r requirements-check.txt \
    -r requirements-test.txt && \
  pip wheel -w ../dist -f dist-requirements --no-cache-dir . 

RUN \
  pip install --no-index -f dist awscli && \
  aws --version

FROM pypiserver/pypiserver:latest

COPY --from=builder /home/builder/dist /data/packages
COPY install /usr/local/bin/install
COPY pipx /usr/local/bin/pipx
COPY tarball /usr/local/bin/tarball
COPY entrypoint /usr/local/bin/entrypoint

EXPOSE 8080 

ENTRYPOINT [ "/bin/sh", "-c" ]
CMD [ "entrypoint" ]
