# syntax=docker/dockerfile:1.3-labs

ARG PYTHON_VERSION=3.10
ARG ALPINE_VERSION=3.14
FROM python:$PYTHON_VERSION-alpine$ALPINE_VERSION

ARG AWSCLI_VERSION=2.2.45

ENV PYTHON_VERSION=$PYTHON_VERSION
ENV ALPINE_VERSION=$ALPINE_VERSION
ENV AWSCLI_VERSION=$AWSCLI_VERSION

RUN apk add --no-cache sudo make groff less libffi openssl

ARG USER=test
ENV USER=$USER

COPY make_account .
RUN ./make_account $USER

COPY entrypoint /bin/entrypoint

USER $USER
WORKDIR /home/$USER
RUN mkdir -p ./.local/bin
ENV PATH=/home/$USER/.local/bin:$PATH

RUN pip install --disable-pip-version-check -U pip setuptools wheel
RUN python -m venv .venv

ENTRYPOINT ["/bin/entrypoint" ]
CMD [ "/bin/sh" ]
