# syntax=docker/dockerfile:1.3-labs

ARG PYTHON_VERSION=3.10
ARG ALPINE_VERSION=3.14
FROM python:$PYTHON_VERSION-alpine$ALPINE_VERSION

ARG AWSCLI_VERSION=2.2.45

ENV PYTHON_VERSION=$PYTHON_VERSION
ENV ALPINE_VERSION=$ALPINE_VERSION
ENV AWSCLI_VERSION=$AWSCLI_VERSION

RUN apk add --no-cache sudo make groff less libffi openssl

ARG USER=builder
ENV USER=$USER

COPY make_account .
RUN ./make_account $USER

COPY entrypoint /bin/entrypoint

USER $USER
WORKDIR /home/$USER
RUN mkdir -p ./.local/bin
ENV PATH=/home/$USER/.local/bin:$PATH

COPY Makefile .

RUN make clone
RUN make repo-test
RUN make virtualenv
RUN make pip-update
RUN make build
RUN make install
RUN make pip-purge

EXPOSE 3141

ENTRYPOINT ["/bin/entrypoint" ]
CMD [ "--version" ]
