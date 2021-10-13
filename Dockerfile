ARG ALPINE_VERSION
FROM alpine:$ALPINE_VERSION

ARG AWSCLI_VERSION

RUN \
  apk update && \
  apk add \
    bash \
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
    py3-pip \
    sudo 

RUN \
  addgroup bezos && \
  adduser -G bezos -D bezos && \
  addgroup bezos wheel && \
  echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER bezos
WORKDIR /home/bezos
RUN mkdir -p ./.local/bin
ENV PATH=/home/builder/.local/bin:$PATH

RUN \
  git clone https://github.com/aws/aws-cli --branch v2 && \
  cd aws-cli && \
  git checkout -b $AWSCLI_VERSION

RUN python3 -m venv .venv && \
  . .venv/bin/activate && \
  pip install -U pip setuptools wheel && \
  pip install -r aws-cli/requirements-runtime.txt

# test for pinned botocore egg in requirements-runtime.txt (break docker build if/when this changes)
RUN \
  grep -q 'https://github.com/boto/botocore/zipball/v2#egg=botocore' aws-cli/requirements-runtime.txt

# read musl_libc version with ldd for the wheel platform tag
RUN \
  . .venv/bin/activate && \
  cd aws-cli && \
  MUSL_LIBC_VERSION=$(ldd 2>&1 | awk -F'[ \.]' '/Version/{printf("%s_%s", $2, $3)}') && \
  PLATFORM_TAG="musllinux_${MUSL_LIBC_VERSION}_$(uname -m)" && \
  python setup.py bdist_wheel --plat-name "$PLATFORM_TAG" && \
  pip install dist/*.whl

RUN \
  echo '[ -v VIRTUAL_ENV ] || . .venv/bin/activate' >.bashrc && \
  echo '. .bashrc' >.bash_profile

ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD [ "aws --version" ]
