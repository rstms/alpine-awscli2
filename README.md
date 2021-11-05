alpine-awscli
-------------

A pythonic method for installing awscli v2 on alpine.

## Features:
- Uses docker containers to minimize dev system config requirements
- Reads current release version from dockerhub `official` aws-cli image
- Installs awscli source from AWS github repo without code modification
- Builds in dockerhub `official` alpine image
- Offers multiple methods for installing awscli on alpine containers
- No root requirement
- Installs into venv

## Quick Start: `pip`
Install awscli on an alpine system with docker
```
eval $(docker run rstms/alpine-awscli:latest install)
```

Install awscli using `pipx`
```
eval $(docker run rstms/alpine-awscli:latest pipx)
```

## Dev System Requirements:
These are required for building the install image.  To install, only
docker is required.

Resource     | Reference
------------ | --------------
alpine       | https://www.alpinelinux.org
docker       | https://wiki.alpinelinux.org/wiki/Docker#Installation
make         | `apk add make`

## Development
```
git clone git@github.com:rstms/alpine-awscli2
cd alpine-awscli2
make build && make test && make publish 
```

## Make Targets:
Target  | Description
------- | -----------
build   | build a docker image, pull module source from github; build wheel files
wheels  | copy the wheels from the image to local `wheels` directory
tarball | create `awscli-wheels.tgz` gzipped tar archive containing the wheels in a package directory
test    | run the tests (examples)
publish | tag with alpine and awscli versions and push to dockerhub 


## Detailed Description:
The installation installs prerequisite software, configures the system to build the
compiled modules, clones the the AWS github repo aws/aws_cli, selects the `v2` branch,
then compiles the distribution files with `pip wheel`

This results in a set of wheel files which are the result of the compilation, which
can subsequently be installed to an alpine system with pip.

The container build continues based on the pypiserver/pypiserver dockerhub image,
which can be run as a local PyPi-compatible module repository.

The resulting image contains the wheel files for all modules required for
awscli int the directory `/data/packages`.  The wheel files may be extracted
as a tarball, copied to a directory, or the build image may be run as a repo
and used with the command:
```
pip install -i http://locahost:8080 awscli
```

See the examples for various methods of installation. 

*Use the source, Luke.*


### Why does this project exist? 

While the `awscli` package on PyPi `just works` for python2 users, those
who wish to use current python versions or require the expanded V2 features
discover that version 2 is not available using the expected idiom:
`pip install awscli>=2.0.0`

AWS has chosen not to distribute aws-cli V2.X.X and its botocore dependency on PyPi.

Their suggested installation is documented here:
 - https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

While this method works for the 'supported' environments, it fails on alpine
linux due to glibc dependency, which isn't required for the awscli module.

This has invited some small amount of discussion:
 - https://github.com/aws/aws-cli/issues/4947

*This project is a humble attempt to solve the problem for one developer,
released in the hope that it may be of use to others.*
