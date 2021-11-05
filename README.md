alpine-awscli
-------------

A pythonic method for installing awscli v2 on alpine.

## Features:
- Simple `Dockerfile` with standard git clone, python deployment commands
- Uses docker container to minimize dev system config requirements
- Reads current release version from `official` dockerhub aws-cli image
- Installs aws-cli source from AWS github repo with no code modification
- Builds using dockerhub `official` alpine image
- Optional: includes https://github.com/pypiserver/pypiserver to run as local repo
- Offers multiple methods for installing awscli on alpine containers
- No root requirement for awscli install
- Flexible, pythonic module install: user, venv, pipx

## Installation Requirements
On Alpine Linux, in a container, VM, bare metal, one needs:
Resource     | Reference
------------ | --------------
alpine       | https://www.alpinelinux.org
python3      | `apk add python3 py3-pip`
docker       | https://wiki.alpinelinux.org/wiki/Docker#Installation
make         | `apk add make` (development only; not needed to install from dockerhub)

## Quick Start (fast and convenient)

 > Security Note: While this doesn't use `sudo`, it's still rather too trusting.
 > It's never a good idea to run unknown commands with `eval` or by piping `curl` 
 > results into `sudo` or `bash`.
 > To output the commands being passed to `eval`, just run the command inside the parenthesis.
 > You can also capture this output to a file to make your own shell script.

Install awscli using `docker` and `pip`:
```
eval $(docker run rstms/alpine-awscli:latest install)
```

Install awscli using `docker` and `pipx`:
```
eval $(docker run rstms/alpine-awscli:latest pipx)
```

## Development
To fork your own, you'll need github and dockerhub accounts.
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
tarball | create `awscli-wheels.tgz` containing the wheels in a `package` directory
test    | run the tests (examples)
publish | tag with alpine and awscli versions and push to dockerhub 


## Detailed Description:
The `build/Dockerfile` installs prerequisite software, configures the system to build the
compiled modules, clones the the AWS github repo aws/aws-cli, selects the `v2` branch,
then prepares a distribution package using `pip wheel`

This results in a set of the wheel files required for awscli which can be installed to an
alpine system with pip or any compatible alternative.

The container build then continues from the pypiserver/pypiserver dockerhub image,
which can be run as a local PyPi-compatible module repository.

The resulting image contains the wheel files for all modules required for
awscli in the directory `/data/packages`.  The wheel files may be extracted
as a tarball, copied to a directory, or the build image may be run as a repo
and used with the command:
```
pip install -i http://locahost:8080 awscli
```

See the examples for various alternative installation methods.

*Use the source, Luke.*


### Why does this project exist? 

While the `awscli` package on PyPi *just works* for python2 users, those
who wish to use current python versions or require the expanded V2 features
may discover to their dismay that version 2 is not available using the expected
 idiom: `pip install awscli==2.X.X`

AWS has chosen not to distribute aws-cli V2.X.X and its botocore dependency on PyPi.

Their suggested installation is documented here:
 - https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

While this method works on the list of supported environments, it fails on Alpine
Linux due to limitations of the non-standard installation mechanism.  One problem
involves glibc dependency, but this isn't a requirement for the awscli module or
for any of its dependencies despite what many have written.  With proper system
configuration, unmodified AWS sources build and install without issue using
just the standard Python tools on Alpine.

The dockerhub image provides a minimal configuration single command installation.
This workaround respects the PyPi license terms, which disallow distribution of
unmodified clones of a project's packages when the owner has chosen not to publish
on PyPi.  Otherwise we could all just use PyPi and pip.

This situation has resulted in a fair amount of discussion:
 - https://github.com/aws/aws-cli/issues/4947 (Note how this thead ends)

*This project is a humble attempt to solve a problem for one developer,
released in the hope that it may be of use to others.*
