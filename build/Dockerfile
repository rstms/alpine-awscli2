# syntax=docker/dockerfile:1.3-labs

ARG PYTHON_VERSION=3.10
ARG ALPINE_VERSION=3.14
FROM python:$PYTHON_VERSION-alpine$ALPINE_VERSION

ARG AWSCLI_VERSION=2.2.45

RUN apk add --no-cache sudo groff less libffi openssl
ARG USER=bezos
RUN \
  addgroup $USER && \
  adduser -G $USER -D $USER && \
  addgroup $USER wheel

COPY <<EOF /etc/sudoers.d/wheel-group
%wheel ALL=(ALL) NOPASSWD: ALL
EOF

COPY <<EOF /bin/entrypoint
#!/bin/sh
. /home/$USER/.venv/bin/activate
exec aws \"\$@\"
EOF

RUN chmod 0755 /bin/entrypoint

COPY <<EOF /home/$USER/exports
export AWSCLI_VERSION=$AWSCLI_VERSION
export ALPINE_VERSION=$ALPINE_VERSION
export PYTHON_VERSION=$PYTHON_VERSION
EOF

RUN \
  chmod 0600 /home/$USER/exports && \
  chown $USER.$USER /home/$USER/exports

USER $USER
WORKDIR /home/$USER
RUN mkdir -p ./.local/bin
ENV PATH=/home/$USER/.local/bin:$PATH

# git-clone the aws/aws-cli repo
RUN \
  sudo apk add --no-cache --virtual .git-pkg git && \
  git clone https://github.com/aws/aws-cli --branch v2 && \
  cd aws-cli && \
  git checkout -b $AWSCLI_VERSION && \
  sudo apk del --no-network .git-pkg

# test for pinned botocore egg in requirements-runtime.txt (break docker build if/when this changes)
RUN grep -q 'https://github.com/boto/botocore/zipball/v2#egg=botocore' aws-cli/requirements-runtime.txt 

# read musl_libc version with ldd for the wheel platform tag and set exports variables
RUN \
  ldd 2>&1 | awk -F'[ \.]' '/Version/{printf("export MUSL_LIBC_VERSION=%s_%s\n", $2, $3)}' >>exports && \
  . exports && \
  echo "export PLATFORM_TAG=musllinux_${MUSL_LIBC_VERSION}_$(uname -m)" >>exports

# debug
RUN cat exports

# add build packages; build and install; remove packakges
RUN \
  # load env vars
  . exports && \
  # add build packages
  sudo apk add --no-cache --virtual .build-pkg \
    cmake \
    g++ \
    libffi-dev \
    make \
    openssl-dev && \
  # create, activate virtualenv
  python3 -m venv .venv && \
  . .venv/bin/activate && \
  pip install --no-cache-dir --upgrade pip setuptools wheel && \
  # install the aws-cli requirements into the virtualenv
  pip install --no-cache-dir --requirement aws-cli/requirements-runtime.txt && \
  cd aws-cli && \
  # build the aws-cli wheel
  python setup.py bdist_wheel --plat-name "$PLATFORM_TAG" && \
  # install the aws-cli using the new wheel
  pip install --no-cache-dir dist/*.whl && \
  # clear the pip cache
  pip cache purge && \
  # delete build packages
  sudo apk del --no-network .build-pkg

COPY <<EOF .local/bin/build_wheels
#!/bin/sh
sudo apk add make cmake g++ libffi-dev openssl-dev
. ~/exports
. ~/.venv/bin/activate
cd aws-cli
pip wheel -w /mnt/dist -r requirements-runtime.txt
cp requirements*.txt /mnt/dist
cp dist/*.whl /mnt/dist
EOF

USER root
RUN \
  chmod 0700 .local/bin/build_wheels && \
  chown $USER.$USER .local/bin/build_wheels
USER $USER

ENTRYPOINT ["/bin/entrypoint" ]
CMD [ "--version" ]
