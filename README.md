alpine-awscli2
--------------

A pythonic method for installing awscli v2 on alpine.

## Features:
- Reads current release version from dockerhub `official` aws-cli image
- Installs from AWS github repo without code modification
- Builds in dockerhub `official` alpine image


## Requirements:
Resource     | Reference
------------ | --------------
alpine       | https://www.alpinelinux.org
docker       | https://wiki.alpinelinux.org/wiki/Docker#Installation
make         | `apk add make`

## Quick Start:
```
git clone git@github.com:rstms/alpine-awscli2
cd alpine-awscli2
make pip_install
```

## Make Targets:
Target  | Description
------- | -----------
build   | build a docker image, pull module source from github; build wheel file
wheel   | start the image and copy the wheel to the local filesystem


## Detailed Descripton:
The installation performs all necessary configuration while building
a docker image.  Once the image is built, a `wheel` is copied to the 
target system.  At this point the docker image is no longer used.

Details will be added in when final method is determined.

Until then, the work is all done in `Dockerfile`
*Use the source, Luke.*


### Why does this project exist? 

While the `awscli` package on PyPi `just works` for python2 users, those
who use a python version less than 11 years out of date, or who wish
to access new AWS features will soon discover that version 2 is not
available for `pip install`

AWS has chosen not to distribute aws-cli V2.X.X and its botocore dependency on PyPi.

The suggested installation is documented here:
 - https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

This has invited some small amount of discussion:
 - https://github.com/aws/aws-cli/issues/4947

This project is a humble attempt to solve the problem for one developer,
released in the hope that it may be of use to others.


`#ifdef RANT_MODE`
This distribution mechanism apparently suits the intents and purposes of 
AWS. Unfortunately it does so at the cost of a clean and well controlled
python runtime configuration.  This adds to the workload for those whose
requirements necessitate management of their systems with more care and
intention.  Such folk are reasonably less than enthusiastic about the 
suggestion of installing security critical software by piping unverified
curl output through sudo.
`#endif` 
