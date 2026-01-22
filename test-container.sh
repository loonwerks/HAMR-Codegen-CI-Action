#! /bin/bash

set -Eeuxo pipefail

: "${GITHUB_WORKSPACE:=/home/runner/work}"
: "${aadl_dir:=.}"
: "${platform:=Microkit}"
: "${package_name:=platform}"

TAGNAME=local/test-hamr-codegen:latest

docker build --tag ${TAGNAME} .

docker run --rm -v $1:${GITHUB_WORKSPACE} \
    -e GITHUB_WORKSPACE=${GITHUB_WORKSPACE} \
    -e GITHUB_OUTPUT='/dev/stdout' \
    --entrypoint /entrypoint.sh \
    ${TAGNAME} \
    "${aadl_dir}" "${platform}" "${package_name}"
