# syntax=docker/dockerfile:1.3-labs

ARG ALPINE_VERSION=latest
FROM alpine:$ALPINE_VERSION

ARG AWSCLI_VERSION=2.2.45

RUN \
  apk --no-cache update && \
  apk --no-cache add \
    cmake \
    g++ \
    gcc \
    git \
    groff \
    less \
    libffi-dev \
    make \
    openssl-dev \
    python3-dev \
    py3-pip 

ARG USER=bezos
RUN addgroup $USER && adduser -G $USER -D $USER 

COPY <<EOF /bin/entrypoint
#!/bin/sh
. /home/$USER/.venv/bin/activate
exec aws \"\$@\"
EOF

RUN chmod 0755 /bin/entrypoint

COPY <<EOF /home/$USER/exports
export AWSCLI_VERSION=$AWSCLI_VERSION
export ALPINE_VERSION=$ALPINE_VERSION
EOF

RUN \
  chmod 0600 /home/$USER/exports && \
  chown $USER.$USER /home/$USER/exports

USER $USER
WORKDIR /home/$USER
RUN mkdir -p ./.local/bin
ENV PATH=/home/$USER/.local/bin:$PATH

RUN \
  git clone https://github.com/aws/aws-cli --branch v2 && \
  cd aws-cli && \
  git checkout -b $AWSCLI_VERSION

RUN \
  python3 -m venv .venv && \
  . .venv/bin/activate && \
  pip install --no-cache-dir --upgrade pip setuptools wheel && \
  pip install --no-cache-dir --requirement aws-cli/requirements-runtime.txt

# test for pinned botocore egg in requirements-runtime.txt (break docker build if/when this changes)
RUN \
  grep -q 'https://github.com/boto/botocore/zipball/v2#egg=botocore' aws-cli/requirements-runtime.txt

# read musl_libc version with ldd for the wheel platform tag
# 
RUN \
  . .venv/bin/activate && \
  cd aws-cli && \
  MUSL_LIBC_VERSION=$(ldd 2>&1 | awk -F'[ \.]' '/Version/{printf("%s_%s", $2, $3)}') && \
  PLATFORM_TAG="musllinux_${MUSL_LIBC_VERSION}_$(uname -m)" && \
  python setup.py bdist_wheel --plat-name "$PLATFORM_TAG" && \
  pip install --no-cache-dir dist/*.whl && \
  echo "export MUSL_LIBC_VERSION=$MUSL_LIBC_VERSION" >>~/exports && \
  echo "export PLATFORM_TAG=$PLATFORM_TAG" >>~/exports 

COPY <<EOF spin_wheels
#!/bin/sh
export PATH=~/.local/bin:$PATH
. ~/exports
. ~/.venv/bin/activate
cd aws-cli
pip wheel -w /mnt/dist -r requirements.txt
cp requirements*.txt /mnt/dist
cp dist/*.whl /mnt/dist
EOF

USER root
RUN chmod 0700 spin_wheels && chown $USER.$USER spin_wheels
USER $USER

ENTRYPOINT ["/bin/entrypoint" ]
CMD [ "--version" ]
